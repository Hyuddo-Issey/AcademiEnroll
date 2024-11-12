namespace AcademiEnroll.Models
{
    using System.ComponentModel.DataAnnotations;

    public class Docente
    {
        [Key]
        public int Id { get; set; }
        public string Nombre { get; set; }
        public string Correo { get; set; }
        public string Clave { get; set; }
        public string Rol { get; set; }
        // Otras propiedades relevantes para Docente
    }

}
