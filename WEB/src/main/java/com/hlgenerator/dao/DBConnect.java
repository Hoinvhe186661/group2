package com.hlgenerator.dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBConnect {
    protected Connection connection;
    private static final Logger logger = Logger.getLogger(DBConnect.class.getName());
    
    // Database configuration
    private static final String DB_URL = "jdbc:mysql://localhost:3306/hlelectric?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";

    public DBConnect() {
        try {
            // Load database properties
            Properties props = loadDatabaseProperties();
            
            String url = props.getProperty("db.url", DB_URL);
            String user = props.getProperty("db.username", DB_USER);
            String password = props.getProperty("db.password", DB_PASSWORD);
            String driver = props.getProperty("db.driver", DB_DRIVER);
            
            logger.info("Connecting to database: " + url);
            logger.info("Using driver: " + driver);
            
            // Load MySQL driver
            Class.forName(driver);
            
            // Create connection
            connection = DriverManager.getConnection(url, user, password);
            
            if (connection != null && !connection.isClosed()) {
                logger.info("Database connection successful!");
            } else {
                logger.severe("Failed to establish database connection");
            }
            
        } catch (ClassNotFoundException e) {
            logger.log(Level.SEVERE, "MySQL JDBC Driver not found", e);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database connection failed", e);
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            logger.severe("Message: " + e.getMessage());
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error during database connection", e);
        }
    }
    
    private Properties loadDatabaseProperties() {
        Properties props = new Properties();
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties")) {
            if (input != null) {
                props.load(input);
                logger.info("Loaded database properties from file");
            } else {
                logger.warning("database.properties file not found, using default values");
            }
        } catch (IOException e) {
            logger.warning("Could not load database.properties: " + e.getMessage());
        }
        return props;
    }
    
    public Connection getConnection() {
        try {
            // Kiểm tra connection hiện tại
            if (connection != null && !connection.isClosed()) {
                return connection;
            }
            
            // Nếu connection bị đóng, tạo mới
            Properties props = loadDatabaseProperties();
            String url = props.getProperty("db.url", DB_URL);
            String user = props.getProperty("db.username", DB_USER);
            String password = props.getProperty("db.password", DB_PASSWORD);
            String driver = props.getProperty("db.driver", DB_DRIVER);
            
            Class.forName(driver);
            connection = DriverManager.getConnection(url, user, password);
            logger.info("Created new database connection");
            
            return connection;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error creating database connection", e);
            return null;
        }
    }
    
    public boolean isConnected() {
        try {
            return connection != null && !connection.isClosed();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking connection status", e);
            return false;
        }
    }
    
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                logger.info("Database connection closed");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error closing database connection", e);
        }
    }



    public static void main(String[] args) {
        DBConnect dbConnect = new DBConnect();
        if (dbConnect.isConnected()) {
            System.out.println("Kết nối database thành công!");
        } else {
            System.out.println("Kết nối database thất bại!");
        }
        dbConnect.closeConnection();
    }
}


