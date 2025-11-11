<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>403 - Forbidden</title>
	<link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">
</head>
<body>
	<div class="container" style="margin-top:60px;">
		<div class="jumbotron">
			<h1>403</h1>
			<p>Bạn không có quyền truy cập trang này.</p>
			<p><a class="btn btn-primary btn-lg" href="<%= request.getContextPath() %>/index.jsp">Về trang chủ</a></p>
		</div>
	</div>
</body>
</html>


