package com.hlgenerator.servlet;

import com.hlgenerator.dao.TaskDAO;
import com.hlgenerator.model.Task;
import com.hlgenerator.model.TaskAssignment;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/api/tasks")
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
				result.put("data", new JSONArray(items));
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
			if ("acknowledge".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				boolean ok = taskDAO.updateTaskStatus(taskId, "in_progress", new Timestamp(System.currentTimeMillis()), null, null, null);
				out.print(jsonResult(ok, ok ? "Đã nhận nhiệm vụ" : "Không thể cập nhật").toString());
			} else if ("complete".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				String notes = request.getParameter("notes");
				String actual = request.getParameter("actualHours");
				BigDecimal actualHours = actual != null && !actual.isEmpty() ? new BigDecimal(actual) : null;
				boolean ok = taskDAO.updateTaskStatus(taskId, "completed", null, new Timestamp(System.currentTimeMillis()), notes, actualHours);
				out.print(jsonResult(ok, ok ? "Đã hoàn thành nhiệm vụ" : "Không thể cập nhật").toString());
			} else if ("updateNotes".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("id"));
				String notes = request.getParameter("notes");
				boolean ok = taskDAO.updateTaskStatus(taskId, null, null, null, notes, null);
				out.print(jsonResult(ok, ok ? "Đã lưu ghi chú" : "Không thể lưu ghi chú").toString());
			} else {
				out.print(jsonResult(false, "Hành động không hợp lệ").toString());
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
}


