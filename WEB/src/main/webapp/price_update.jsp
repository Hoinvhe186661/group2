<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cập nhật giá bán</title>
    <link href="<%=request.getContextPath()%>/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet" type="text/css" />
</head>
<body class="skin-black">
<div class="container" style="margin-top:20px;">
    <a class="btn btn-default" href="<%=request.getContextPath()%>/product.jsp">
        <i class="fa fa-arrow-left"></i> Quay lại danh sách
    </a>

    <h3 style="margin-top:15px;">Cập nhật giá bán</h3>

    <div class="panel panel-default">
        <div class="panel-body">
            <form id="updatePriceForm" class="form-inline" onsubmit="return submitUpdatePrice(event)">
                <input type="hidden" id="productId" value="<%=request.getParameter("productId") != null ? request.getParameter("productId") : ""%>">
                <div class="form-group" style="margin-right:10px;">
                    <label for="currentPrice">Giá hiện tại:</label>
                    <input type="text" id="currentPrice" class="form-control" style="min-width: 180px;" disabled>
                </div>
                <div class="form-group" style="margin-right:10px;">
                    <label for="newPrice">Giá mới:</label>
                    <input type="number" id="newPrice" class="form-control" step="1000" required>
                </div>
                <div class="form-group" style="margin-right:10px; width: 420px;">
                    <label for="reason">Lý do:</label>
                    <input type="text" id="reason" class="form-control" placeholder="Ví dụ: Điều chỉnh theo thị trường" style="width:100%;" oninput="updateReasonCounter()">
                    <small class="form-text text-muted"><span id="reasonCounter" style="color:#5cb85c;">0</span> / 50 từ</small>
                </div>
                <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Lưu</button>
            </form>
        </div>
    </div>

    <div id="notice" class="alert alert-warning" style="display:none;"></div>

    <div class="panel panel-default">
        <div class="panel-heading">Lịch sử giá bán gần đây</div>
        <div class="panel-body">
            <table class="table table-bordered table-striped">
                <thead>
                    <tr>
                        <th>Thời gian</th>
                        <th>Giá cũ</th>
                        <th>Giá mới</th>
                        <th>Người cập nhật</th>
                        <th>Lý do</th>
                    </tr>
                </thead>
                <tbody id="historyBody">
                    <tr><td colspan="5" class="text-center">Đang tải...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="<%=request.getContextPath()%>/js/jquery.min.js" type="text/javascript"></script>
<script src="<%=request.getContextPath()%>/js/bootstrap.min.js" type="text/javascript"></script>
<script>
(function init(){
    var pid = document.getElementById('productId').value;
    if(!pid){ alert('Thiếu productId'); return; }
    // Lấy thông tin sản phẩm
    $.get('<%=request.getContextPath()%>/product', { action: 'view', id: pid }, function(res){
        if(res && res.success){
            $('#currentPrice').val(new Intl.NumberFormat('vi-VN').format(res.product.unitPrice || 0) + ' VNĐ');
        }
    }, 'json');
    // Lấy lịch sử giá bán
    loadHistory();
})();

function loadHistory(){
    var pid = document.getElementById('productId').value;
    $('#historyBody').html('<tr><td colspan="5" class="text-center">Đang tải...</td></tr>');
    $.get('<%=request.getContextPath()%>/product', { action: 'priceHistory', productId: pid, type: 'selling', limit: 10 }, function(res){
        if(!res || !res.success){ $('#historyBody').html('<tr><td colspan="5" class="text-center">Không tải được lịch sử</td></tr>'); return; }
        var rows = '';
        if(res.data && res.data.length){
            res.data.forEach(function(h){
                rows += '<tr>'+
                    '<td>' + (h.updatedAt || '') + '</td>'+
                    '<td>' + (h.oldPrice==null? '—' : new Intl.NumberFormat('vi-VN').format(h.oldPrice)) + '</td>'+
                    '<td>' + (h.newPrice==null? '—' : new Intl.NumberFormat('vi-VN').format(h.newPrice)) + '</td>'+
                    '<td>' + (h.updatedByName || '') + '</td>'+
                    '<td>' + (h.reason || '') + '</td>'+
                '</tr>';
            });
        } else {
            rows = '<tr><td colspan="5" class="text-center">Chưa có lịch sử</td></tr>';
        }
        $('#historyBody').html(rows);
        if (res.count >= 3) {
            $('#notice').text('Lưu ý: Giá bán đã được cập nhật ' + res.count + ' lần. Hãy xác nhận kỹ trước khi thay đổi tiếp.').show();
        } else {
            $('#notice').hide();
        }
    }, 'json');
}

function submitUpdatePrice(e){
    e.preventDefault();
    var pid = document.getElementById('productId').value;
    var price = document.getElementById('newPrice').value;
    var reason = document.getElementById('reason').value;
    // validate reason word count <= 50
    var words = reason && reason.trim().length ? reason.trim().split(/\s+/).filter(function(w){return w.length>0;}) : [];
    if (words.length > 50){
        document.getElementById('reasonCounter').style.color = '#d9534f';
        document.getElementById('reason').style.borderColor = '#d9534f';
        alert('Lý do không được vượt quá 50 từ (hiện tại: ' + words.length + ').');
        return false;
    }
    if(!price || parseFloat(price) <= 0){ alert('Giá mới phải > 0'); return false; }
    $.post('<%=request.getContextPath()%>/product', { action: 'updatePrice', productId: pid, newPrice: price, reason: reason }, function(res){
        if(res && res.success){
            alert(res.message || 'Cập nhật thành công');
            // reload current price and history
            $.get('<%=request.getContextPath()%>/product', { action: 'view', id: pid }, function(r){
                if(r && r.success){ $('#currentPrice').val(new Intl.NumberFormat('vi-VN').format(r.product.unitPrice || 0) + ' VNĐ'); }
            }, 'json');
            loadHistory();
            document.getElementById('newPrice').value = '';
            document.getElementById('reason').value = '';
        } else {
            alert(res && res.message ? res.message : 'Cập nhật thất bại');
        }
    }, 'json').fail(function(xhr){
        alert('Lỗi server: ' + (xhr.responseText || ''));
    });
    return false;
}

function updateReasonCounter(){
    var reason = document.getElementById('reason').value || '';
    var words = reason.trim().length ? reason.trim().split(/\s+/).filter(function(w){return w.length>0;}) : [];
    var counter = document.getElementById('reasonCounter');
    counter.textContent = words.length;
    if (words.length > 50){
        counter.style.color = '#d9534f';
        document.getElementById('reason').style.borderColor = '#d9534f';
    } else {
        counter.style.color = '#5cb85c';
        document.getElementById('reason').style.borderColor = '';
    }
}
</script>
</body>
</html>


