<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý kho</title>
    <link href="<%=request.getContextPath()%>/admin/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/admin/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/admin/css/style.css" rel="stylesheet" type="text/css" />
</head>
<body class="skin-black">
    <header class="header">
        <a href="<%=request.getContextPath()%>/admin/admin.jsp" class="logo">Bảng điều khiển quản trị</a>
        <nav class="navbar navbar-static-top" role="navigation"></nav>
    </header>
    <div class="wrapper row-offcanvas row-offcanvas-left">
        <aside class="left-side sidebar-offcanvas">
            <section class="sidebar">
                <ul class="sidebar-menu">
                    <li>
                        <a href="<%=request.getContextPath()%>/products.jsp"><i class="fa fa-shopping-cart"></i> <span>Quản lý sản phẩm</span></a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/suppliers.jsp"><i class="fa fa-industry"></i> <span>Nhà cung cấp</span></a>
                    </li>
                    <li class="active">
                        <a href="<%=request.getContextPath()%>/inventory.jsp"><i class="fa fa-archive"></i> <span>Quản lý kho</span></a>
                    </li>
                </ul>
            </section>
        </aside>
        <aside class="right-side">
            <section class="content">
                <h3>Quản lý kho</h3>
                <p>Trang này sẽ hiển thị tồn kho theo sản phẩm và kho.</p>
            </section>
        </aside>
    </div>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/admin/js/bootstrap.min.js" type="text/javascript"></script>
</body>
</html>









