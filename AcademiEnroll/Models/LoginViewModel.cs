using System.ComponentModel.DataAnnotations;

namespace AcademiEnroll.Models
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "El campo Correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "El formato del correo no es válido.")]
        public string Correo { get; set; }

        [Required(ErrorMessage = "El campo Clave es obligatorio.")]
        [DataType(DataType.Password)]
        public string Clave { get; set; }
    }
}
