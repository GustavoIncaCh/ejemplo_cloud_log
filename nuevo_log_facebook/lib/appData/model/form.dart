class FeedbackForm {
  String _id;
  String _nombre;
  String _area;
  String _comentario;

  FeedbackForm(this._id, this._nombre, this._area, this._comentario);

  // Method to make GET parameters.
  String toParams() =>
      "?id=$_id&nombre=$_nombre&area=$_area&comentario=$_comentario";
}
