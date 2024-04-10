import 'dart:ui';

class Recognition {

  String name;

  Rect location;
  List<double> embeddings;
  double distance;
  String id;
  String imageUrl;
  /// Constructs a Category.
  Recognition(this.name,this.location,this.embeddings,this.distance, this.id,this.imageUrl);

}
