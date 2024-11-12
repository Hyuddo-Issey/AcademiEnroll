// Función para mostrar alerta de error de login
function mostrarErrorLogin(mensaje) {
    if (mensaje) {
        Swal.fire({
            icon: 'error',
            title: 'Error de autenticación',
            text: mensaje,
            confirmButtonText: 'Aceptar'
        });
    }
}

// Verificar si hay un mensaje de error y mostrarlo cuando la página se haya cargado
document.addEventListener("DOMContentLoaded", function () {
    var loginError = document.getElementById('loginErrorMessage').innerText;
    mostrarErrorLogin(loginError);
});
