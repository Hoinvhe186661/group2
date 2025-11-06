// Global notification (floating toasts)
(function(window, document) {
    'use strict';

    function createContainer() {
        var container = document.getElementById('toastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toastContainer';
            container.className = 'floating-toast-container';
            document.body.appendChild(container);
        }
        return container;
    }

    function mapType(type) {
        if (!type) return 'info';
        type = String(type).toLowerCase();
        if (['success','danger','info','warning'].indexOf(type) === -1) return 'info';
        return type;
    }

    function showToast(type, message, timeout) {
        var container = createContainer();
        var t = mapType(type);

        var toast = document.createElement('div');
        toast.className = 'floating-toast ' + t;
        toast.setAttribute('role', 'alert');
        toast.innerHTML = '<span class="toast-message">' + (message || '') + '</span>' +
                          '<span class="toast-close" aria-label="Đóng">&times;</span>';

        // close handler
        toast.querySelector('.toast-close').addEventListener('click', function() {
            hideToast(toast);
        });

        container.appendChild(toast);

        // force reflow to enable transition
        window.getComputedStyle(toast).opacity;
        toast.classList.add('show');

        var removeAfter = (typeof timeout === 'number') ? timeout : 5000;
        var timeoutId = setTimeout(function() {
            hideToast(toast);
        }, removeAfter);

        // hide and remove
        function hideToast(el) {
            if (!el) return;
            el.classList.remove('show');
            setTimeout(function() { try { el.remove(); } catch(e){} }, 250);
            clearTimeout(timeoutId);
        }

        return {
            element: toast,
            close: function() { hideToast(toast); }
        };
    }

    // Flexible showAlert wrapper to be compatible with existing pages
    // Supports both showAlert(type, message) and showAlert(message, type)
    function showAlertFlexible(a, b, timeout) {
        var type, message;
        // if first arg looks like a known type
        var known = ['success','danger','info','warning'];
        if (typeof a === 'string' && known.indexOf(a.toLowerCase()) !== -1) {
            type = a; message = b;
        } else if (typeof b === 'string' && known.indexOf(b.toLowerCase()) !== -1) {
            type = b; message = a;
        } else {
            // default
            type = 'info'; message = (a || b || '');
        }
        showToast(type, message, timeout);
    }

    // Expose global APIs
    window.showToast = showToast;
    window.showAlert = showAlertFlexible;

})(window, document);
