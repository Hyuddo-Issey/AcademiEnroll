using Microsoft.AspNetCore.Mvc;
using AcademiEnroll.Models;
using AcademiEnroll.Data;
using System.Linq;
using Microsoft.AspNetCore.Authorization;

public class CuentaController : Controller
{
    private readonly AcademiEnrollContext _context;

    
    public CuentaController(AcademiEnrollContext context)
    {
        _context = context;
    }

    // Creacion de la vista principal de Login
    public IActionResult Login() => View();

    // Creacion de la logica para procesar el Login
    [HttpPost]
    public IActionResult Login(string correo, string clave)
    {
        var usuario = _context.Usuarios.SingleOrDefault(u => u.Correo == correo && u.Clave == clave);
        if (usuario != null)
        {
            if (usuario.Rol == "Administrador") return RedirectToAction("VistaAdmin");
            if (usuario.Rol == "Docente") return RedirectToAction("VistaDocente");
            return RedirectToAction("VistaEstudiante");
        }
        ModelState.AddModelError("", "Usuario o contraseña incorrectos.");
        return View();
    }

    // Creacion de  la vista de Registro
    public IActionResult Registro() => View();

    // Creacion de la logica que Procesa el registro de un nuevo usuario
    [HttpPost]
    public IActionResult Registro(Usuario usuario, string confirmarClave)
    {
        if (ModelState.IsValid && usuario.Clave == confirmarClave)
        {
            // Guardar el usuario en la base de datos
            _context.Usuarios.Add(usuario);
            _context.SaveChanges();

            ViewBag.Nombre = usuario.Nombre;
            ViewBag.Rol = usuario.Rol;

            return View("ConfirmacionRegistro");  // Redirige a la vista de confirmación
        }

        ModelState.AddModelError("", "Error al registrar el usuario.");
        return View();
    }



    // Creacion de la vista de confirmación tras el registro
    public IActionResult ConfirmacionRegistro(string correo)
    {
        ViewBag.Correo = correo;
        return View();
    }

    // Creacion de la vista de "Olvidé mi contraseña"
    public IActionResult OlvidoContraseña() => View();

    // Creacion de la logica para procesar la solicitud de restablecimiento de contraseña
    [HttpPost]
    public IActionResult OlvidoContraseña(string correo)
    {
        var usuario = _context.Usuarios.SingleOrDefault(u => u.Correo == correo);
        if (usuario != null)
        {
            // Aquí puedes generar una contraseña temporal o un enlace de restablecimiento
            // Por ahora, vamos a simular el restablecimiento estableciendo una contraseña predeterminada.
            usuario.Clave = "nueva_contraseña123"; // Puedes usar lógica más segura en producción
            _context.SaveChanges();

            ViewBag.Mensaje = "Se ha restablecido su contraseña. Revise su correo o use 'nueva_contraseña123' como clave temporal.";
        }
        else
        {
            ViewBag.Mensaje = "No se encontró una cuenta con ese correo.";
        }

        return View();
    }


    // Creación de la vista para el Docente
    public IActionResult VistaDocente() => View("VistaDocente");

    // Creación de la vista para el Estudiante
    public IActionResult VistaEstudiante() => View("VistaEstudiante");

    // Creación de la vista para el Administrador
    public IActionResult VistaAdmin() => View("VistaAdmin");

    
}
