package com.hlgenerator.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hlgenerator.dao.FeedbackDAO;
import com.hlgenerator.dao.SupportRequestDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/api/feedback")
@MultipartConfig(
    maxFileSize = 10485760,      // 10MB
    maxRequestSize = 11534336,   // 11MB (10MB + buffer)
    fileSizeThreshold = 2097152  // 2MB
)
public class FeedbackServlet extends HttpServlet {
    
    private FeedbackDAO feedbackDAO;
    private SupportRequestDAO supportDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        supportDAO = new SupportRequestDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("isLoggedIn") == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
                out.print(jsonResponse.toString());
                return;
            }
            
            String action = request.getParameter("action");
            
            if ("getByTicketId".equals(action)) {
                // Lấy feedback theo ticket ID
                String ticketIdParam = request.getParameter("ticketId");
                if (ticketIdParam == null || ticketIdParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu ticket ID");
                } else {
                    try {
                        int ticketId = Integer.parseInt(ticketIdParam);
                        
                        // Kiểm tra ticket có tồn tại và thuộc về khách hàng đang đăng nhập không
                        Integer customerId = (Integer) session.getAttribute("customerId");
                        if (customerId == null) {
                            customerId = (Integer) session.getAttribute("userId");
                        }
                        
                        Map<String, Object> ticket = supportDAO.getSupportRequestById(ticketId);
                        if (ticket == null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không tìm thấy ticket");
                        } else {
                            // Kiểm tra ticket có thuộc về khách hàng này không
                            Object ticketCustomerId = ticket.get("customerId");
                            if (ticketCustomerId != null && customerId != null) {
                                int ticketCustId = ((Number) ticketCustomerId).intValue();
                                if (ticketCustId != customerId.intValue()) {
                                    jsonResponse.addProperty("success", false);
                                    jsonResponse.addProperty("message", "Không có quyền xem feedback của ticket này");
                                } else {
                                    Map<String, Object> feedback = feedbackDAO.getFeedbackMapByTicketId(ticketId);
                                    if (feedback != null) {
                                        jsonResponse.addProperty("success", true);
                                        jsonResponse.add("data", gson.toJsonTree(feedback));
                                    } else {
                                        jsonResponse.addProperty("success", true);
                                        jsonResponse.addProperty("data", (String) null);
                                        jsonResponse.addProperty("message", "Chưa có feedback");
                                    }
                                }
                            } else {
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "Không thể xác định khách hàng");
                            }
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Ticket ID không hợp lệ");
                    }
                }
                
            } else if ("getStats".equals(action)) {
                // Lấy thống kê rating (admin và customer_support có thể xem)
                String userRole = (String) session.getAttribute("userRole");
                if ("admin".equals(userRole) || "customer_support".equals(userRole)) {
                    Map<String, Object> stats = feedbackDAO.getRatingStats();
                    jsonResponse.addProperty("success", true);
                    jsonResponse.add("data", gson.toJsonTree(stats));
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Không có quyền xem thống kê");
                }
            } else if ("list".equals(action)) {
                // Lấy danh sách tất cả feedback (admin và customer_support)
                String userRole = (String) session.getAttribute("userRole");
                if ("admin".equals(userRole) || "customer_support".equals(userRole)) {
                    // Lấy filter parameters
                    String customerName = request.getParameter("customerName");
                    String ticketNumber = request.getParameter("ticketNumber");
                    String ratingParam = request.getParameter("rating");
                    String category = request.getParameter("category");
                    
                    Integer rating = null;
                    if (ratingParam != null && !ratingParam.trim().isEmpty()) {
                        try {
                            rating = Integer.parseInt(ratingParam);
                        } catch (NumberFormatException e) {
                            // Ignore invalid rating
                        }
                    }
                    
                    List<Map<String, Object>> feedbacks = feedbackDAO.getAllFeedbacksWithDetails(
                        customerName, ticketNumber, rating, category
                    );
                    jsonResponse.addProperty("success", true);
                    jsonResponse.add("data", gson.toJsonTree(feedbacks));
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Không có quyền xem danh sách feedback");
                }
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        } finally {
            out.print(jsonResponse.toString());
            out.close();
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("isLoggedIn") == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Chưa đăng nhập");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Kiểm tra xem request có phải multipart không
            String contentType = request.getContentType();
            boolean isMultipart = contentType != null && contentType.toLowerCase().startsWith("multipart/form-data");
            
            String action = null;
            String ticketIdParam = null;
            String ratingParam = null;
            String comment = null;
            String feedbackIdParam = null;
            String imagePath = null;
            
            if (isMultipart) {
                // Xử lý multipart request (có file upload)
                action = request.getParameter("action");
                if (action == null) {
                    action = "create";
                }
                
                ticketIdParam = request.getParameter("ticketId");
                ratingParam = request.getParameter("rating");
                comment = request.getParameter("comment");
                feedbackIdParam = request.getParameter("feedbackId");
                
                // Xử lý upload ảnh
                Part imagePart = request.getPart("image");
                if (imagePart != null && imagePart.getSize() > 0) {
                    try {
                        imagePath = handleImageUpload(imagePart, request);
                    } catch (Exception e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", e.getMessage());
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            } else {
                // Xử lý form thông thường (không có file)
                action = request.getParameter("action");
                if (action == null) {
                    action = "create";
                }
                
                ticketIdParam = request.getParameter("ticketId");
                ratingParam = request.getParameter("rating");
                comment = request.getParameter("comment");
                feedbackIdParam = request.getParameter("feedbackId");
            }
            
            if ("create".equals(action)) {
                // Tạo feedback mới
                
                if (ticketIdParam == null || ticketIdParam.trim().isEmpty() ||
                    ratingParam == null || ratingParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin ticket ID hoặc rating");
                } else {
                    try {
                        int ticketId = Integer.parseInt(ticketIdParam);
                        int rating = Integer.parseInt(ratingParam);
                        
                        // Validate rating (1-5)
                        if (rating < 1 || rating > 5) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Rating phải từ 1 đến 5");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        // Validate comment - tối đa 1000 ký tự
                        if (comment != null && !comment.trim().isEmpty()) {
                            int charCount = comment.length();
                            if (charCount > 1000) {
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "Nhận xét không được vượt quá 1000 ký tự. Hiện tại bạn đã nhập " + charCount + " ký tự. Vui lòng rút gọn nội dung.");
                                out.print(jsonResponse.toString());
                                return;
                            }
                        }
                        
                        // Lấy customer ID từ session
                        Integer customerId = (Integer) session.getAttribute("customerId");
                        if (customerId == null) {
                            customerId = (Integer) session.getAttribute("userId");
                        }
                        
                        if (customerId == null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không thể xác định khách hàng");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        // Kiểm tra ticket có tồn tại và thuộc về khách hàng này không
                        Map<String, Object> ticket = supportDAO.getSupportRequestById(ticketId);
                        if (ticket == null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không tìm thấy ticket");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        // Kiểm tra ticket có thuộc về khách hàng này không
                        Object ticketCustomerId = ticket.get("customerId");
                        if (ticketCustomerId == null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Ticket không hợp lệ");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        int ticketCustId = ((Number) ticketCustomerId).intValue();
                        if (ticketCustId != customerId.intValue()) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Không có quyền feedback cho ticket này");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        // Kiểm tra ticket đã được resolved chưa
                        String ticketStatus = (String) ticket.get("status");
                        if (!"resolved".equals(ticketStatus) && !"closed".equals(ticketStatus)) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Chỉ có thể feedback cho ticket đã được giải quyết (resolved hoặc closed)");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        // Kiểm tra xem ticket đã có feedback chưa - KHÔNG cho phép tạo mới nếu đã có
                        com.hlgenerator.model.Feedback existingFeedback = feedbackDAO.getFeedbackByTicketId(ticketId);
                        if (existingFeedback != null) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Ticket này đã có feedback. Không thể tạo feedback mới hoặc chỉnh sửa.");
                            out.print(jsonResponse.toString());
                            return;
                        }
                        
                        // Tạo feedback
                        boolean success = feedbackDAO.createFeedback(ticketId, customerId.intValue(), rating, comment, imagePath);
                        
                        if (success) {
                            jsonResponse.addProperty("success", true);
                            jsonResponse.addProperty("message", "Cảm ơn bạn đã gửi feedback!");
                        } else {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Lỗi tạo feedback: " + feedbackDAO.getLastError());
                        }
                        
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Ticket ID hoặc rating không hợp lệ");
                    }
                }
                
            } else if ("update".equals(action)) {
                // Cập nhật feedback
                if (feedbackIdParam == null || feedbackIdParam.trim().isEmpty() ||
                    ratingParam == null || ratingParam.trim().isEmpty()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Thiếu thông tin");
                } else {
                    try {
                        int feedbackId = Integer.parseInt(feedbackIdParam);
                        int rating = Integer.parseInt(ratingParam);
                        
                        if (rating < 1 || rating > 5) {
                            jsonResponse.addProperty("success", false);
                            jsonResponse.addProperty("message", "Rating phải từ 1 đến 5");
                        } else {
                            // Lấy feedback cũ để xử lý ảnh
                            com.hlgenerator.model.Feedback oldFeedback = feedbackDAO.getFeedbackById(feedbackId);
                            String finalImagePath = imagePath;
                            
                            // Nếu có ảnh mới, xóa ảnh cũ nếu có
                            if (imagePath != null && isMultipart && oldFeedback != null && oldFeedback.getImagePath() != null) {
                                deleteOldImage(oldFeedback.getImagePath(), request);
                            } else if (oldFeedback != null && oldFeedback.getImagePath() != null) {
                                // Nếu không có ảnh mới, giữ nguyên ảnh cũ
                                finalImagePath = oldFeedback.getImagePath();
                            }
                            
                            boolean success = feedbackDAO.updateFeedback(feedbackId, rating, comment, finalImagePath);
                            if (success) {
                                jsonResponse.addProperty("success", true);
                                jsonResponse.addProperty("message", "Cập nhật feedback thành công");
                            } else {
                                jsonResponse.addProperty("success", false);
                                jsonResponse.addProperty("message", "Lỗi cập nhật: " + feedbackDAO.getLastError());
                            }
                        }
                    } catch (NumberFormatException e) {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "ID không hợp lệ");
                    }
                }
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Action không hợp lệ");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Lỗi server: " + e.getMessage());
        } finally {
            out.print(jsonResponse.toString());
            out.close();
        }
    }
    
    /**
     * Xử lý upload ảnh feedback
     */
    private String handleImageUpload(Part imagePart, HttpServletRequest request) throws Exception {
        // Kiểm tra file có tồn tại không
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }
        
        // Kiểm tra kích thước file (10MB)
        long fileSize = imagePart.getSize();
        if (fileSize > 10 * 1024 * 1024) {
            throw new Exception("Kích thước ảnh quá lớn. Tối đa 10MB.");
        }
        
        // Kiểm tra định dạng file
        String fileName = getFileName(imagePart);
        if (fileName == null || fileName.isEmpty()) {
            return null;
        }
        
        String extension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        if (!extension.matches("jpg|jpeg|png|gif|webp")) {
            throw new Exception("Định dạng ảnh không hợp lệ. Chỉ chấp nhận JPG, PNG, GIF, WEBP.");
        }
        
        // Tạo tên file unique
        String uniqueFileName = UUID.randomUUID().toString() + "." + extension;
        
        // Đường dẫn thư mục upload
        String uploadPath = request.getServletContext().getRealPath("/uploads/feedback/");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Lưu file
        File uploadedFile = new File(uploadDir, uniqueFileName);
        imagePart.write(uploadedFile.getAbsolutePath());
        
        // Trả về đường dẫn relative
        return "uploads/feedback/" + uniqueFileName;
    }
    
    /**
     * Lấy tên file từ Part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) {
            return null;
        }
        
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                String fileName = token.substring(token.indexOf("=") + 2, token.length() - 1);
                // Xử lý trường hợp có đường dẫn đầy đủ
                if (fileName.contains("\\")) {
                    fileName = fileName.substring(fileName.lastIndexOf("\\") + 1);
                }
                if (fileName.contains("/")) {
                    fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
                }
                return fileName;
            }
        }
        return null;
    }
    
    /**
     * Xóa ảnh cũ khi cập nhật feedback
     */
    private void deleteOldImage(String imagePath, HttpServletRequest request) {
        if (imagePath == null || imagePath.isEmpty()) {
            return;
        }
        
        try {
            String fullPath = request.getServletContext().getRealPath("/" + imagePath);
            File oldFile = new File(fullPath);
            if (oldFile.exists()) {
                oldFile.delete();
            }
        } catch (Exception e) {
            // Log lỗi nhưng không throw exception
            System.err.println("Error deleting old image: " + e.getMessage());
        }
    }
    
}

