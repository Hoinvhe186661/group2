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

    public DBConnect() {
        try {
            // Load properties from database.properties file
            Properties props = new Properties();
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("database.properties");
            
            if (inputStream == null) {
                Logger.getLogger(DBConnect.class.getName()).log(Level.SEVERE, "database.properties file not found!");
                return;
            }
            
            props.load(inputStream);
            
            // Get database connection properties
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");
            String url = props.getProperty("db.url");
            String driver = props.getProperty("db.driver");
            
            // Load JDBC driver
            Class.forName(driver);
            
            // Create connection
            connection = DriverManager.getConnection(url, user, pass);
            
            inputStream.close();
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBConnect.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception ex) {
            Logger.getLogger(DBConnect.class.getName()).log(Level.SEVERE, "Error loading database properties", ex);
        }
    }

    /**
     * Get the connection instance
     * @return Connection object
     */
    public Connection getConnection() {
        return connection;
    }

    /**
     * Static method to get a new database connection from properties
     * @return Connection object
     * @throws SQLException if connection fails
     * @throws ClassNotFoundException if driver not found
     */
    public static Connection getConnectionFromProperties() throws SQLException, ClassNotFoundException {
        try {
            // Load properties from database.properties file
            Properties props = new Properties();
            InputStream inputStream = DBConnect.class.getClassLoader().getResourceAsStream("database.properties");
            
            if (inputStream == null) {
                throw new SQLException("database.properties file not found!");
            }
            
            props.load(inputStream);
            
            // Get database connection properties
            String user = props.getProperty("db.username");
            String pass = props.getProperty("db.password");
            String url = props.getProperty("db.url");
            String driver = props.getProperty("db.driver");
            
            // Load JDBC driver
            Class.forName(driver);
            
            // Create and return connection
            Connection conn = DriverManager.getConnection(url, user, pass);
            
            inputStream.close();
            return conn;
        } catch (IOException ex) {
            Logger.getLogger(DBConnect.class.getName()).log(Level.SEVERE, "Error loading database properties", ex);
            throw new SQLException("Error loading database properties", ex);
        }
    }

    // Test connect
    public static void main(String[] args) {
        DBConnect db = new DBConnect();
        if (db.connection != null) {
            System.out.println("Database connection successful!");
        } else {
            System.out.println("Failed to connect to the database.");
        }
    }
}
