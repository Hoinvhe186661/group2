package com.hlgenerator.dao;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.hlgenerator.model.WorkOrder;

public class WorkOrderDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(WorkOrderDAO.class.getName());

    public WorkOrderDAO() {
        super();
        if (connection == null) {
            logger.severe("WorkOrderDAO: Database connection failed during initialization");
        }
    }

    // Check database connection
    private boolean checkConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                logger.severe("Database connection is not available");
                return false;
            }
            return true;
        } catch (SQLException e) {
            logger.severe("Error checking database connection: " + e.getMessage());
            return false;
        }
    }

    /**
     * Generate unique work order number
     * Format: [Random Letters]-[4 digits]
     * Example: WO-1234, ABC-5678, XYZ-9012
     */
    public String generateWorkOrderNumber() {
        java.util.Random random = new java.util.Random();
        int maxAttempts = 100; // Tối đa 100 lần thử để tránh vòng lặp vô hạn
        
        // Danh sách các chữ cái để tạo prefix random
        String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        
        for (int attempt = 0; attempt < maxAttempts; attempt++) {
            // Tạo 2-3 chữ cái ngẫu nhiên cho prefix
            int prefixLength = 2 + random.nextInt(2); // 2 hoặc 3 chữ cái
            StringBuilder prefixBuilder = new StringBuilder();
            for (int i = 0; i < prefixLength; i++) {
                prefixBuilder.append(letters.charAt(random.nextInt(letters.length())));
            }
            String prefix = prefixBuilder.toString() + "-";
            
            // Tạo 4 số ngẫu nhiên (0000-9999)
            int randomNumber = random.nextInt(10000); // 0-9999
            String numberPart = String.format("%04d", randomNumber); // Format thành 4 chữ số với leading zeros
            
            // Tạo mã: prefix + 4 số
            String workOrderNumber = prefix + numberPart;
            
            // Kiểm tra xem mã đã tồn tại chưa
            if (!isWorkOrderNumberExists(workOrderNumber)) {
                return workOrderNumber;
            }
        }
        
        // Nếu sau 100 lần thử vẫn không tìm được mã unique, dùng timestamp làm fallback
        logger.warning("Could not generate unique work order number after " + maxAttempts + " attempts, using timestamp");
        String fallbackPrefix = "WO-";
        return fallbackPrefix + String.format("%04d", (int)(System.currentTimeMillis() % 10000)); // Lấy 4 chữ số cuối của timestamp
    }
    
    /**
     * Kiểm tra xem work order number đã tồn tại chưa
     */
    private boolean isWorkOrderNumberExists(String workOrderNumber) {
        if (!checkConnection()) {
            return false;
        }
        
        String sql = "SELECT COUNT(*) as count FROM work_orders WHERE work_order_number = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, workOrderNumber);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error checking work order number existence: " + workOrderNumber, e);
            // Nếu có lỗi, giả sử mã đã tồn tại để tránh duplicate
            return true;
        }
        
        return false;
    }

    /**
     * Create new work order
     */
    public WorkOrder createWorkOrder(WorkOrder workOrder) {
        if (!checkConnection()) {
            logger.severe("Cannot create work order: Database connection unavailable");
            return null;
        }

        String sql = "INSERT INTO work_orders (work_order_number, customer_id, contract_id, title, description, " +
                     "priority, status, assigned_to, estimated_hours, scheduled_date, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            // Generate work order number if not provided
            if (workOrder.getWorkOrderNumber() == null || workOrder.getWorkOrderNumber().isEmpty()) {
                workOrder.setWorkOrderNumber(generateWorkOrderNumber());
            }

            ps.setString(1, workOrder.getWorkOrderNumber());
            ps.setInt(2, workOrder.getCustomerId());
            
            if (workOrder.getContractId() != null) {
                ps.setInt(3, workOrder.getContractId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            
            ps.setString(4, workOrder.getTitle());
            ps.setString(5, workOrder.getDescription());
            ps.setString(6, workOrder.getPriority());
            ps.setString(7, workOrder.getStatus());
            
            if (workOrder.getAssignedTo() != null) {
                ps.setInt(8, workOrder.getAssignedTo());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            
            if (workOrder.getEstimatedHours() != null) {
                ps.setBigDecimal(9, workOrder.getEstimatedHours());
            } else {
                ps.setNull(9, Types.DECIMAL);
            }
            
            if (workOrder.getScheduledDate() != null) {
                ps.setDate(10, workOrder.getScheduledDate());
            } else {
                ps.setNull(10, Types.DATE);
            }
            
            if (workOrder.getCreatedBy() != null) {
                ps.setInt(11, workOrder.getCreatedBy());
            } else {
                ps.setNull(11, Types.INTEGER);
            }

            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        workOrder.setId(generatedKeys.getInt(1));
                    }
                }
                
                logger.info("Work order created successfully: " + workOrder.getWorkOrderNumber());
                return workOrder;
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating work order", e);
        }
        
        return null;
    }

    /**
     * Get work order by ID
     */
    public WorkOrder getWorkOrderById(int id) {
        if (!checkConnection()) {
            return null;
        }

        // Join with users and customers tables
        String sql = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                     "FROM work_orders wo " +
                     "LEFT JOIN users u ON wo.assigned_to = u.id " +
                     "LEFT JOIN customers c ON wo.customer_id = c.id " +
                     "WHERE wo.id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToWorkOrder(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting work order by ID: " + id, e);
        }
        
        return null;
    }

    /**
     * Get work order by work order number
     */
    public WorkOrder getWorkOrderByNumber(String workOrderNumber) {
        if (!checkConnection()) {
            return null;
        }

        // Join with users and customers tables
        String sql = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                     "FROM work_orders wo " +
                     "LEFT JOIN users u ON wo.assigned_to = u.id " +
                     "LEFT JOIN customers c ON wo.customer_id = c.id " +
                     "WHERE wo.work_order_number = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, workOrderNumber);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToWorkOrder(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting work order by number: " + workOrderNumber, e);
        }
        
        return null;
    }

    /**
     * Get work order by ticket info (title and customer ID)
     * This is used to check if a ticket already has an associated work order
     */
    public WorkOrder getWorkOrderByTicketInfo(String title, int customerId) {
        if (!checkConnection()) {
            return null;
        }

        // Join with users and customers tables
        // Match by title (case-insensitive, trimmed) and customer_id
        String sql = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                     "FROM work_orders wo " +
                     "LEFT JOIN users u ON wo.assigned_to = u.id " +
                     "LEFT JOIN customers c ON wo.customer_id = c.id " +
                     "WHERE TRIM(wo.title) = ? AND wo.customer_id = ? " +
                     "LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, title.trim());
            ps.setInt(2, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToWorkOrder(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting work order by ticket info (title: " + title + ", customerId: " + customerId + ")", e);
        }
        
        return null;
    }
    
    /**
     * Get work order by ticket ID
     * Tìm work order liên kết với ticket bằng cách:
     * 1. Tìm trong description có [TICKET_ID:xxx]
     * 2. Nếu không tìm thấy, tìm theo title và customer_id từ ticket
     */
    public WorkOrder getWorkOrderByTicketId(int ticketId, String ticketTitle, int customerId) {
        if (!checkConnection()) {
            return null;
        }
        
        // Method 1: Tìm work order có description chứa [TICKET_ID:ticketId]
        String sql1 = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                      "FROM work_orders wo " +
                      "LEFT JOIN users u ON wo.assigned_to = u.id " +
                      "LEFT JOIN customers c ON wo.customer_id = c.id " +
                      "WHERE wo.description LIKE ? " +
                      "LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(sql1)) {
            ps.setString(1, "%[TICKET_ID:" + ticketId + "]%");
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToWorkOrder(rs);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting work order by ticket ID (method 1): " + ticketId, e);
        }
        
        // Method 2: Tìm theo title và customer_id
        if (ticketTitle != null && !ticketTitle.trim().isEmpty() && customerId > 0) {
            return getWorkOrderByTicketInfo(ticketTitle.trim(), customerId);
        }
        
        return null;
    }

    /**
     * Get all work orders
     */
    public List<WorkOrder> getAllWorkOrders() {
        List<WorkOrder> workOrders = new ArrayList<>();
        
        if (!checkConnection()) {
            return workOrders;
        }

        // Join with users and customers tables
        String sql = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                     "FROM work_orders wo " +
                     "LEFT JOIN users u ON wo.assigned_to = u.id " +
                     "LEFT JOIN customers c ON wo.customer_id = c.id " +
                     "ORDER BY wo.created_at DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                workOrders.add(mapResultSetToWorkOrder(rs));
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all work orders", e);
        }
        
        return workOrders;
    }

    /**
     * Get work orders by customer ID
     */
    public List<WorkOrder> getWorkOrdersByCustomerId(int customerId) {
        List<WorkOrder> workOrders = new ArrayList<>();
        
        if (!checkConnection()) {
            return workOrders;
        }

        // Join with users and customers tables
        String sql = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                     "FROM work_orders wo " +
                     "LEFT JOIN users u ON wo.assigned_to = u.id " +
                     "LEFT JOIN customers c ON wo.customer_id = c.id " +
                     "WHERE wo.customer_id = ? " +
                     "ORDER BY wo.created_at DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    workOrders.add(mapResultSetToWorkOrder(rs));
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting work orders for customer: " + customerId, e);
        }
        
        return workOrders;
    }

    /**
     * Get work orders assigned to a user
     */
    public List<WorkOrder> getWorkOrdersByAssignedTo(int userId) {
        List<WorkOrder> workOrders = new ArrayList<>();
        
        if (!checkConnection()) {
            return workOrders;
        }

        // Join with users and customers tables
        String sql = "SELECT wo.*, u.full_name AS assigned_to_name, c.contact_person AS customer_name " +
                     "FROM work_orders wo " +
                     "LEFT JOIN users u ON wo.assigned_to = u.id " +
                     "LEFT JOIN customers c ON wo.customer_id = c.id " +
                     "WHERE wo.assigned_to = ? " +
                     "ORDER BY wo.created_at DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    workOrders.add(mapResultSetToWorkOrder(rs));
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting work orders for user: " + userId, e);
        }
        
        return workOrders;
    }

    /**
     * Update work order
     */
    public boolean updateWorkOrder(WorkOrder workOrder) {
        if (!checkConnection()) {
            return false;
        }

        // Build dynamic SQL to include technical_solution if column exists
        String sql = "UPDATE work_orders SET customer_id = ?, contract_id = ?, title = ?, description = ?, " +
                     "priority = ?, status = ?, assigned_to = ?, estimated_hours = ?, actual_hours = ?, " +
                     "scheduled_date = ?, completion_date = ?";
        
        // Always include technical_solution in UPDATE (assume column exists)
        // If column doesn't exist, the SQL will fail and we'll catch the error
        sql += ", technical_solution = ?";
        logger.info("Adding technical_solution to UPDATE SQL");
        
        sql += " WHERE id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, workOrder.getCustomerId());
            
            if (workOrder.getContractId() != null) {
                ps.setInt(2, workOrder.getContractId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            
            ps.setString(3, workOrder.getTitle());
            ps.setString(4, workOrder.getDescription());
            ps.setString(5, workOrder.getPriority());
            ps.setString(6, workOrder.getStatus());
            
            if (workOrder.getAssignedTo() != null) {
                ps.setInt(7, workOrder.getAssignedTo());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            
            if (workOrder.getEstimatedHours() != null) {
                ps.setBigDecimal(8, workOrder.getEstimatedHours());
            } else {
                ps.setNull(8, Types.DECIMAL);
            }
            
            if (workOrder.getActualHours() != null) {
                ps.setBigDecimal(9, workOrder.getActualHours());
            } else {
                ps.setNull(9, Types.DECIMAL);
            }
            
            if (workOrder.getScheduledDate() != null) {
                ps.setDate(10, workOrder.getScheduledDate());
            } else {
                ps.setNull(10, Types.DATE);
            }
            
            if (workOrder.getCompletionDate() != null) {
                ps.setDate(11, workOrder.getCompletionDate());
            } else {
                ps.setNull(11, Types.DATE);
            }
            
            int paramIndex = 12;
            // Always set technical_solution parameter
            if (workOrder.getTechnicalSolution() != null && !workOrder.getTechnicalSolution().trim().isEmpty()) {
                ps.setString(paramIndex++, workOrder.getTechnicalSolution());
                logger.info("Setting technical_solution parameter: " + workOrder.getTechnicalSolution().substring(0, Math.min(50, workOrder.getTechnicalSolution().length())) + "...");
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
                logger.info("Setting technical_solution parameter to NULL (empty or null value)");
            }
            
            ps.setInt(paramIndex, workOrder.getId());
            logger.info("Executing UPDATE work_orders SQL with " + paramIndex + " parameters");
            logger.info("SQL: " + sql);
            logger.info("Work Order ID: " + workOrder.getId());
            logger.info("Technical Solution: " + (workOrder.getTechnicalSolution() != null ? 
                ("'" + workOrder.getTechnicalSolution().substring(0, Math.min(100, workOrder.getTechnicalSolution().length())) + 
                (workOrder.getTechnicalSolution().length() > 100 ? "..." : "") + "' (length: " + workOrder.getTechnicalSolution().length() + ")") : "null"));

            int affectedRows = ps.executeUpdate();
            logger.info("UPDATE affected rows: " + affectedRows);
            return affectedRows > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating work order", e);
            return false;
        }
    }

    /**
     * Delete work order
     */
    public boolean deleteWorkOrder(int id) {
        if (!checkConnection()) {
            return false;
        }

        String sql = "DELETE FROM work_orders WHERE id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting work order: " + id, e);
            return false;
        }
    }

    /**
     * Map ResultSet to WorkOrder object
     */
    private WorkOrder mapResultSetToWorkOrder(ResultSet rs) throws SQLException {
        WorkOrder workOrder = new WorkOrder();
        
        workOrder.setId(rs.getInt("id"));
        workOrder.setWorkOrderNumber(rs.getString("work_order_number"));
        workOrder.setCustomerId(rs.getInt("customer_id"));
        
        int contractId = rs.getInt("contract_id");
        if (!rs.wasNull()) {
            workOrder.setContractId(contractId);
        }
        
        workOrder.setTitle(rs.getString("title"));
        workOrder.setDescription(rs.getString("description"));
        workOrder.setPriority(rs.getString("priority"));
        workOrder.setStatus(rs.getString("status"));
        
        int assignedTo = rs.getInt("assigned_to");
        if (!rs.wasNull()) {
            workOrder.setAssignedTo(assignedTo);
        }
        
        BigDecimal estimatedHours = rs.getBigDecimal("estimated_hours");
        if (estimatedHours != null) {
            workOrder.setEstimatedHours(estimatedHours);
        }
        
        BigDecimal actualHours = rs.getBigDecimal("actual_hours");
        if (actualHours != null) {
            workOrder.setActualHours(actualHours);
        }
        
        Date scheduledDate = rs.getDate("scheduled_date");
        if (scheduledDate != null) {
            workOrder.setScheduledDate(scheduledDate);
        }
        
        Date completionDate = rs.getDate("completion_date");
        if (completionDate != null) {
            workOrder.setCompletionDate(completionDate);
        }
        
        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) {
            workOrder.setCreatedBy(createdBy);
        }
        
        workOrder.setCreatedAt(rs.getTimestamp("created_at"));
        workOrder.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Get assigned user name (may be null if no JOIN or no assignment)
        try {
            String assignedToName = rs.getString("assigned_to_name");
            if (assignedToName != null && !assignedToName.isEmpty()) {
                workOrder.setAssignedToName(assignedToName);
            }
        } catch (SQLException e) {
            // Column might not exist in some queries, ignore
        }
        
        // Get customer name (may be null if no JOIN)
        try {
            String customerName = rs.getString("customer_name");
            if (customerName != null && !customerName.isEmpty()) {
                workOrder.setCustomerName(customerName);
            }
        } catch (SQLException e) {
            // Column might not exist in some queries, ignore
        }
        
        // Get technical solution (may not exist in database yet)
        try {
            String technicalSolution = rs.getString("technical_solution");
            if (technicalSolution != null) {
                workOrder.setTechnicalSolution(technicalSolution);
            }
        } catch (SQLException e) {
            // Column might not exist in database yet, ignore
        }
        
        return workOrder;
    }
}


