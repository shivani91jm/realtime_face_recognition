import 'dart:ui';

class Recognition {

  String name;

  Rect location;
  List<double> embeddings;
  double distance;
  String id;
  String imageUrl;
  String image2;
  /// Constructs a Category.
  Recognition(this.name,this.location,this.embeddings,this.distance, this.id,this.imageUrl,this.image2);

}
