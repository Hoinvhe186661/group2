package com.hlgenerator.servlet;

import com.hlgenerator.dao.TaskDAO;
import com.hlgenerator.model.Task;
import com.hlgenerator.model.TaskAssignment;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@WebServlet("/api/tasks")
@MultipartConfig(
	maxFileSize = 5242880,      // 5MB
	maxRequestSize = 26214400,  // 25MB
	fileSizeThreshold = 1048576 // 1MB
)
public class TaskServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TaskDAO taskDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		taskDAO = new TaskDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");
		response.setContentType("application/json; charset=UTF-8");

		String action = request.getParameter("action");
		PrintWriter out = response.getWriter();

		try {
			if ("listAssigned".equals(action)) {
				int userId = Integer.parseInt(param(request, "userId", "0"));
				String status = request.getParameter("status");
				String priority = request.getParameter("priority");
				String scheduledFrom = request.getParameter("scheduledFrom");
				String scheduledTo = request.getParameter("scheduledTo");
				String keyword = request.getParameter("q");
				java.sql.Date from = null, to = null;
				try { if (scheduledFrom != null && !scheduledFrom.isEmpty()) from = java.sql.Date.valueOf(scheduledFrom); } catch (Exception ignored) {}
				try { if (scheduledTo != null && !scheduledTo.isEmpty()) to = java.sql.Date.valueOf(scheduledTo); } catch (Exception ignored) {}
				int page = Integer.parseInt(param(request, "page", "1"));
				int size = Integer.parseInt(param(request, "size", "10"));
				if (page < 1) page = 1; if (size < 1) size = 10; if (size > 100) size = 100;
				int total = taskDAO.countAssignmentsForUser(userId, status, priority, from, to, keyword);
				int offset = (page - 1) * size;
				List<TaskAssignment> items = taskDAO.getAssignmentsForUserPaged(userId, status, priority, from, to, keyword, size, offset);
				JSONObject result = new JSONObject();
				result.put("success", true);
				JSONArray dataArray = new JSONArray();
				for (TaskAssignment item : items) {
					dataArray.put(item.toJSON());
				}
				result.put("data", dataArray);
				JSONObject meta = new JSONObject();
				meta.put("page", page);
				meta.put("size", size);
				meta.put("total", total);
				meta.put("totalPages", (int)Math.ceil(total / (double)size));
				result.put("meta", meta);
				out.print(result.toString());
			} else if ("get".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				Task task = taskDAO.getTaskById(taskId);
				JSONObject result = new JSONObject();
				result.put("success", task != null);
				result.put("data", task != null ? new JSONObject(task) : JSONObject.NULL);
				out.print(result.toString());
			} else if ("getDetail".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				int userId = Integer.parseInt(param(request, "userId", "0"));
				TaskAssignment assignment = taskDAO.getAssignmentDetail(taskId, userId);
				JSONObject result = new JSONObject();
				if (assignment != null) {
					result.put("success", true);
					result.put("data", assignment.toJSON());
				} else {
					result.put("success", false);
					result.put("message", "Không tìm thấy nhiệm vụ");
				}
				out.print(result.toString());
			} else {
				JSONObject error = new JSONObject();
				error.put("success", false);
				error.put("message", "Hành động không hợp lệ");
				out.print(error.toString());
			}
		} catch (Exception e) {
			JSONObject error = new JSONObject();
			error.put("success", false);
			error.put("message", e.getMessage());
			out.print(error.toString());
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");
		response.setContentType("application/json; charset=UTF-8");

		String action = request.getParameter("action");
		PrintWriter out = response.getWriter();

		try {
			System.out.println("TaskServlet - Action: " + action); // Debug log
			if ("acknowledge".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				boolean ok = taskDAO.updateTaskStatus(taskId, "in_progress", new Timestamp(System.currentTimeMillis()), null, null, null);
				out.print(jsonResult(ok, ok ? "Đã nhận nhiệm vụ" : "Không thể cập nhật").toString());
			} else if ("complete".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				String workDesc = request.getParameter("workDescription");
				String issuesFound = request.getParameter("issuesFound");
				String notes = request.getParameter("notes");
				String actual = request.getParameter("actualHours");
				String percentage = request.getParameter("completionPercentage");
				
				BigDecimal actualHours = actual != null && !actual.isEmpty() 
					? new BigDecimal(actual) : null;
				BigDecimal completionPercentage = percentage != null && !percentage.isEmpty() 
					? new BigDecimal(percentage) : new BigDecimal(100);
				
				// Upload files
				List<String> uploadedFiles = new ArrayList<>();
				try {
					Collection<Part> fileParts = request.getParts();
					
					for (Part filePart : fileParts) {
						if ("files".equals(filePart.getName()) && filePart.getSize() > 0) {
							String fileName = getFileName(filePart);
							if (fileName != null && !fileName.isEmpty()) {
								String uploadPath = getServletContext().getRealPath("/uploads/tasks/");
								File uploadDir = new File(uploadPath);
								if (!uploadDir.exists()) uploadDir.mkdirs();
								
								String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
								String filePath = uploadPath + File.separator + uniqueFileName;
								filePart.write(filePath);
								
								// Lưu relative path
								uploadedFiles.add("uploads/tasks/" + uniqueFileName);
							}
						}
					}
				} catch (Exception e) {
					System.out.println("File upload error: " + e.getMessage());
					// Continue even if file upload fails
				}
				
				// Update task with detailed report
				boolean ok = taskDAO.completeTask(taskId, actualHours, completionPercentage,
				                                 workDesc, issuesFound, notes, uploadedFiles);
				out.print(jsonResult(ok, ok ? "Đã báo cáo hoàn thành!" : "Không thể cập nhật").toString());
			} else if ("updateNotes".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				String notes = request.getParameter("notes");
				boolean ok = taskDAO.updateTaskStatus(taskId, null, null, null, notes, null);
				out.print(jsonResult(ok, ok ? "Đã lưu ghi chú" : "Không thể lưu ghi chú").toString());
			} else if ("reject".equals(action)) {
				System.out.println("TaskServlet - Processing reject action"); // Debug log
				int taskId = Integer.parseInt(request.getParameter("id"));
				String rejectionReason = request.getParameter("rejectionReason");
				System.out.println("TaskServlet - TaskId: " + taskId + ", Reason: " + rejectionReason); // Debug log
				if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
					out.print(jsonResult(false, "Lý do từ chối không được để trống").toString());
					return;
				}
				boolean ok = rejectTaskDirectly(taskId, rejectionReason.trim());
				System.out.println("TaskServlet - Reject result: " + ok); // Debug log
				out.print(jsonResult(ok, ok ? "Đã từ chối nhiệm vụ" : "Không thể từ chối nhiệm vụ").toString());
			} else {
				System.out.println("TaskServlet - Unknown action: " + action); // Debug log
				out.print(jsonResult(false, "Hành động không hợp lệ: " + action).toString());
			}
		} catch (Exception e) {
			out.print(jsonResult(false, e.getMessage()).toString());
		}
	}

	private String param(HttpServletRequest req, String name, String def) {
		String v = req.getParameter(name);
		return v == null || v.isEmpty() ? def : v;
	}

	private JSONObject jsonResult(boolean success, String message) {
		JSONObject o = new JSONObject();
		o.put("success", success);
		o.put("message", message);
		return o;
	}

	private boolean rejectTaskDirectly(int taskId, String rejectionReason) {
		try {
			// Sử dụng thông tin từ database.properties
			java.util.Properties props = new java.util.Properties();
			java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("database.properties");
			props.load(input);
			
			String url = props.getProperty("db.url");
			String user = props.getProperty("db.username");
			String pass = props.getProperty("db.password");
			
			try (java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, pass)) {
				String sql = "UPDATE tasks SET status = 'rejected', rejection_reason = ?, completion_percentage = 0, updated_at = NOW() WHERE id = ?";
				try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
					ps.setString(1, rejectionReason);
					ps.setInt(2, taskId);
					int result = ps.executeUpdate();
					System.out.println("TaskServlet - Direct reject result: " + result);
					return result > 0;
				}
			}
		} catch (Exception e) {
			System.out.println("TaskServlet - Direct reject error: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}

	private String getFileName(Part part) {
		String contentDisposition = part.getHeader("content-disposition");
		if (contentDisposition == null) return null;
		for (String content : contentDisposition.split(";")) {
			if (content.trim().startsWith("filename")) {
				return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
			}
		}
		return null;
	}
}