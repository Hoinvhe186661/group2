package com.hlgenerator.dao;

import com.hlgenerator.model.Customer;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerDAO extends DBConnect {
    private static final Logger logger = Logger.getLogger(CustomerDAO.class.getName());

    public CustomerDAO() {
        super();
        if (connection == null) {
            logger.severe("CustomerDAO: Database connection failed during initialization");
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

    // Add new customer
    public boolean addCustomer(Customer customer) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "INSERT INTO customers (customer_code, company_name, contact_person, email, phone, address, tax_code, customer_type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customer.getCustomerCode());
            ps.setString(2, customer.getCompanyName());
            ps.setString(3, customer.getContactPerson());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhone());
            ps.setString(6, customer.getAddress());
            ps.setString(7, customer.getTaxCode());
            // Chỉ truyền đúng giá trị ENUM cho customer_type
            String type = customer.getCustomerType();
            if (!"individual".equals(type) && !"company".equals(type)) {
                type = "company"; // Giá trị mặc định
            }
            ps.setString(8, type);
            // Chỉ truyền đúng giá trị ENUM cho status
            String status = customer.getStatus();
            if (!"active".equals(status) && !"inactive".equals(status)) {
                status = "active"; // Giá trị mặc định
            }
            ps.setString(9, status);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding customer", e);
            return false;
        }
    }

    // Get all customers
    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();
        if (!checkConnection()) {
            logger.severe("getAllCustomers: Database connection is not available");
            return customers;
        }
        String sql = "SELECT * FROM customers ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
                Customer customer = new Customer(
                    rs.getInt("id"),
                    rs.getString("customer_code"),
                    rs.getString("company_name"),
                    rs.getString("contact_person"),
                    rs.getString("email"),
                    rs.getString("phone"),
                    rs.getString("address"),
                    rs.getString("tax_code"),
                    rs.getString("customer_type"),
                    rs.getString("status"),
                    rs.getTimestamp("created_at"),
                    rs.getTimestamp("updated_at")
                );
                customers.add(customer);
            }
            if (!hasData) {
                logger.warning("getAllCustomers: No data found in customers table");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all customers", e);
        }
        
        return customers;
    }

    // Get customer by ID
    public Customer getCustomerById(int id) {
        String sql = "SELECT * FROM customers WHERE id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                        rs.getInt("id"),
                        rs.getString("customer_code"),
                        rs.getString("company_name"),
                        rs.getString("contact_person"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getString("tax_code"),
                        rs.getString("customer_type"),
                        rs.getString("status"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting customer by ID: " + id, e);
        }
        
        return null;
    }

    // Update customer
    public boolean updateCustomer(Customer customer) {
        if (!checkConnection()) {
            return false;
        }
        String sql = "UPDATE customers SET customer_code=?, company_name=?, contact_person=?, email=?, phone=?, address=?, tax_code=?, customer_type=?, status=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customer.getCustomerCode());
            ps.setString(2, customer.getCompanyName());
            ps.setString(3, customer.getContactPerson());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhone());
            ps.setString(6, customer.getAddress());
            ps.setString(7, customer.getTaxCode());
            // Chỉ truyền đúng giá trị ENUM cho customer_type
            String type = customer.getCustomerType();
            if (!"individual".equals(type) && !"company".equals(type)) {
                type = "company"; // Giá trị mặc định
            }
            ps.setString(8, type);
            // Chỉ truyền đúng giá trị ENUM cho status
            String status = customer.getStatus();
            if (!"active".equals(status) && !"inactive".equals(status)) {
                status = "active"; // Giá trị mặc định
            }
            ps.setString(9, status);
            ps.setInt(10, customer.getId());
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating customer", e);
            return false;
        }
    }

    // Delete customer (soft delete - set status to inactive)
    public boolean deleteCustomer(int id) {
        String sql = "UPDATE customers SET status='inactive', updated_at=CURRENT_TIMESTAMP WHERE id=?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting customer", e);
            return false;
        }
    }

    // Hard delete customer (permanently remove from database)
    public boolean hardDeleteCustomer(int id) {
        String sql = "DELETE FROM customers WHERE id=?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error hard deleting customer", e);
            return false;
        }
    }

    // Check if customer code exists
    public boolean isCustomerCodeExists(String customerCode) {
        String sql = "SELECT COUNT(*) FROM customers WHERE customer_code = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customerCode);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking customer code existence", e);
        }
        
        return false;
    }

    // Check if customer code exists (excluding current customer for updates)
    public boolean isCustomerCodeExists(String customerCode, int excludeId) {
        String sql = "SELECT COUNT(*) FROM customers WHERE customer_code = ? AND id != ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customerCode);
            ps.setInt(2, excludeId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking customer code existence", e);
        }
        
        return false;
    }

    // Search customers
    public List<Customer> searchCustomers(String searchTerm) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM customers WHERE " +
                    "customer_code LIKE ? OR " +
                    "company_name LIKE ? OR " +
                    "contact_person LIKE ? OR " +
                    "email LIKE ? OR " +
                    "phone LIKE ? " +
                    "ORDER BY created_at DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + searchTerm + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Customer customer = new Customer(
                        rs.getInt("id"),
                        rs.getString("customer_code"),
                        rs.getString("company_name"),
                        rs.getString("contact_person"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getString("tax_code"),
                        rs.getString("customer_type"),
                        rs.getString("status"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                    customers.add(customer);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error searching customers", e);
        }
        
        return customers;
    }

    // Generate next customer code
    public String generateNextCustomerCode() {
        String sql = "SELECT MAX(CAST(SUBSTRING(customer_code, 5) AS UNSIGNED)) FROM customers WHERE customer_code LIKE 'CUST%'";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                int maxNumber = rs.getInt(1);
                return String.format("CUST%03d", maxNumber + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error generating customer code", e);
        }
        
        return "CUST001"; // Default first code
    }
}
