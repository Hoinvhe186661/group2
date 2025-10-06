package com.hlgenerator.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBConnect {
    protected Connection connection;

    public DBConnect() {
        try {
            String user = "root";
            String pass = "phuc1374";
            String url = "jdbc:mysql://localhost:3306/hlelectric?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, user, pass);
            try {
                connection.createStatement().execute("SET time_zone = '+07:00'");
            } catch (SQLException ignore) {}
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBConnect.class.getName()).log(Level.SEVERE, null, ex);
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