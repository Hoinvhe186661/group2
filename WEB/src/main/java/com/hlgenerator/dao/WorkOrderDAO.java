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
     */
    public String generateWorkOrderNumber() {
        String prefix = "WO-";
        String sql = "SELECT work_order_number FROM work_orders ORDER BY id DESC LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                String lastNumber = rs.getString("work_order_number");
                if (lastNumber != null && lastNumber.startsWith(prefix)) {
                    try {
                        int num = Integer.parseInt(lastNumber.substring(prefix.length()));
                        return prefix + String.format("%06d", num + 1);
                    } catch (NumberFormatException e) {
                        // Fall through to timestamp-based generation
                    }
                }
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error generating work order number from sequence", e);
        }
        
        // Fallback: Use timestamp
        return prefix + System.currentTimeMillis();
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

        String sql = "UPDATE work_orders SET customer_id = ?, contract_id = ?, title = ?, description = ?, " +
                     "priority = ?, status = ?, assigned_to = ?, estimated_hours = ?, actual_hours = ?, " +
                     "scheduled_date = ?, completion_date = ? WHERE id = ?";

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
            
            ps.setInt(12, workOrder.getId());

            int affectedRows = ps.executeUpdate();
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
        
        return workOrder;
    }
}


