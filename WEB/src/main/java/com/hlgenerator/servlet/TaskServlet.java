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
				// Tự động hủy các task quá start_date mà vẫn pending trước khi load danh sách
				taskDAO.autoCancelOverduePendingTasks();
				
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
				boolean ok = taskDAO.acknowledgeTask(taskId);
				String message = ok ? "Đã nhận nhiệm vụ" : 
					"Không thể nhận nhiệm vụ. Nhiệm vụ phải ở trạng thái 'Chờ nhận' và chưa quá ngày bắt đầu thực hiện.";
				out.print(jsonResult(ok, message).toString());
			} else if ("complete".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				String workDesc = request.getParameter("workDescription");
				String issuesFound = request.getParameter("issuesFound");
				String notes = request.getParameter("notes");
				String actual = request.getParameter("actualHours");
				String percentage = request.getParameter("completionPercentage");
				
				// Validate workDescription
				if (workDesc == null || workDesc.trim().isEmpty()) {
					out.print(jsonResult(false, "Mô tả công việc đã thực hiện không được để trống").toString());
					return;
				}
				String workDescTrimmed = workDesc.trim();
				if (workDescTrimmed.length() < 10) {
					out.print(jsonResult(false, "Mô tả công việc quá ngắn. Vui lòng nhập tối thiểu 10 ký tự để mô tả rõ ràng.").toString());
					return;
				}
				if (workDescTrimmed.length() > 1000) {
					out.print(jsonResult(false, "Mô tả công việc quá dài. Vui lòng nhập tối đa 1000 ký tự.").toString());
					return;
				}
				
				// Validate issuesFound (nếu có nhập)
				String issuesFoundTrimmed = null;
				if (issuesFound != null && !issuesFound.trim().isEmpty()) {
					issuesFoundTrimmed = issuesFound.trim();
					if (issuesFoundTrimmed.length() < 10) {
						out.print(jsonResult(false, "Vấn đề phát sinh quá ngắn. Vui lòng nhập tối thiểu 10 ký tự nếu có nhập.").toString());
						return;
					}
					if (issuesFoundTrimmed.length() > 500) {
						out.print(jsonResult(false, "Vấn đề phát sinh quá dài. Vui lòng nhập tối đa 500 ký tự.").toString());
						return;
					}
				}
				
				// Validate notes (nếu có nhập)
				String notesTrimmed = null;
				if (notes != null && !notes.trim().isEmpty()) {
					notesTrimmed = notes.trim();
					if (notesTrimmed.length() < 10) {
						out.print(jsonResult(false, "Ghi chú bổ sung quá ngắn. Vui lòng nhập tối thiểu 10 ký tự nếu có nhập.").toString());
						return;
					}
					if (notesTrimmed.length() > 1000) {
						out.print(jsonResult(false, "Ghi chú bổ sung quá dài. Vui lòng nhập tối đa 1000 ký tự.").toString());
						return;
					}
				}
				
				// Validate actualHours
				BigDecimal actualHours = null;
				if (actual != null && !actual.isEmpty()) {
					try {
						actualHours = new BigDecimal(actual);
						if (actualHours.compareTo(BigDecimal.ZERO) <= 0) {
							out.print(jsonResult(false, "Số giờ thực tế phải lớn hơn 0").toString());
							return;
						}
					} catch (NumberFormatException e) {
						out.print(jsonResult(false, "Số giờ thực tế không hợp lệ").toString());
						return;
					}
				} else {
					out.print(jsonResult(false, "Số giờ thực tế không được để trống").toString());
					return;
				}
				
				// Validate completionPercentage
				BigDecimal completionPercentage;
				if (percentage != null && !percentage.isEmpty()) {
					try {
						completionPercentage = new BigDecimal(percentage);
						if (completionPercentage.compareTo(new BigDecimal("1")) < 0) {
							out.print(jsonResult(false, "Phần trăm hoàn thành phải lớn hơn hoặc bằng 1%").toString());
							return;
						}
						if (completionPercentage.compareTo(new BigDecimal("100")) > 0) {
							out.print(jsonResult(false, "Phần trăm hoàn thành không được vượt quá 100%").toString());
							return;
						}
					} catch (NumberFormatException e) {
						out.print(jsonResult(false, "Phần trăm hoàn thành không hợp lệ").toString());
						return;
					}
				} else {
					completionPercentage = new BigDecimal(100);
				}
				
			// Validate deadline and start_date before completing
			java.sql.Timestamp[] deadlineAndStart = taskDAO.getTaskDeadlineAndStartDate(taskId);
			java.sql.Timestamp deadline = deadlineAndStart[0];
			java.sql.Timestamp startDate = deadlineAndStart[1];
			
			java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
			boolean isLate = false;
			String lateMessage = "";
			
			// Check if completion is after deadline
			// Deadline should be treated as end of day (23:59:59.999)
			if (deadline != null) {
				// Set deadline to end of day (23:59:59.999)
				java.util.Calendar cal = java.util.Calendar.getInstance();
				cal.setTime(deadline);
				cal.set(java.util.Calendar.HOUR_OF_DAY, 23);
				cal.set(java.util.Calendar.MINUTE, 59);
				cal.set(java.util.Calendar.SECOND, 59);
				cal.set(java.util.Calendar.MILLISECOND, 999);
				java.sql.Timestamp deadlineEndOfDay = new java.sql.Timestamp(cal.getTimeInMillis());
				
				if (now.after(deadlineEndOfDay)) {
					isLate = true;
					long diffMs = now.getTime() - deadlineEndOfDay.getTime();
					long diffDays = diffMs / (1000 * 60 * 60 * 24);
					long diffHours = (diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60);
					if (diffDays > 0) {
						lateMessage = String.format("Nhiệm vụ hoàn thành muộn %d ngày %d giờ so với deadline", diffDays, diffHours);
					} else {
						lateMessage = String.format("Nhiệm vụ hoàn thành muộn %d giờ so với deadline", diffHours);
					}
				}
			}
				
				// Check if completion_date < start_date (should not happen, but validate anyway)
				if (startDate != null && now.before(startDate)) {
					out.print(jsonResult(false, "Ngày hoàn thành không thể trước ngày bắt đầu").toString());
					return;
				}
				
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
				
				// Update task with detailed report (pass isLate to set status = 'completed_late' if late)
				boolean ok = taskDAO.completeTask(taskId, actualHours, completionPercentage,
				                                 workDescTrimmed, issuesFoundTrimmed, notesTrimmed, uploadedFiles, isLate);
				
				// Return message with late warning if applicable
				if (ok) {
					if (isLate) {
						out.print(jsonResult(true, "Đã báo cáo hoàn thành! ⚠️ " + lateMessage + " (Trạng thái: Hoàn thành muộn)").toString());
					} else {
						out.print(jsonResult(true, "Đã báo cáo hoàn thành!").toString());
					}
				} else {
					out.print(jsonResult(false, "Không thể hoàn thành nhiệm vụ. Nhiệm vụ phải ở trạng thái 'Đang thực hiện'").toString());
				}
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
				
				// Validate rejection reason
				if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
					out.print(jsonResult(false, "Lý do từ chối không được để trống").toString());
					return;
				}
				
				String trimmedReason = rejectionReason.trim();
				if (trimmedReason.length() < 10) {
					out.print(jsonResult(false, "Lý do từ chối quá ngắn. Vui lòng nhập tối thiểu 10 ký tự để giải thích rõ ràng").toString());
					return;
				}
				
				if (trimmedReason.length() > 300) {
					out.print(jsonResult(false, "Lý do từ chối quá dài. Vui lòng nhập tối đa 300 ký tự").toString());
					return;
				}
				
				boolean ok = rejectTaskDirectly(taskId, trimmedReason);
				System.out.println("TaskServlet - Reject result: " + ok); // Debug log
				out.print(jsonResult(ok, ok ? "Đã từ chối nhiệm vụ" : "Không thể từ chối nhiệm vụ. Nhiệm vụ phải ở trạng thái 'Chờ nhận'").toString());
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
				String sql = "UPDATE tasks SET status = 'rejected', rejection_reason = ?, completion_percentage = 0, updated_at = NOW() WHERE id = ? AND status = 'pending'";
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