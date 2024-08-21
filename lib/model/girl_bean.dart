

class GirlBean{
   static final int serialVersionUID = 1;

   int? id;
   String? name;
   String? date;
   String? viewCount;
   String? thumbUrl;
   double? height;
   double? width;

   @override
   String toString() {
     return 'GirlBean{id: $id, name: $name, date: $date, viewCount: $viewCount, thumbUrl: $thumbUrl, height: $height, width: $width}';
   }


}