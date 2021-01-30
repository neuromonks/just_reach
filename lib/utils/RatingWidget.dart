import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

typedef void OnRatingChange(int rating);

class StarColor{
  Color defaultColor;
  List<Color> colors = [];

  StarColor({Color defaultColor=Colors.black54, List<Color> colors}){
    this.defaultColor = defaultColor;
    if(colors==null){
      for(int i=0;i<5;i++){
        this.colors.add(defaultColor);

      }
      return;
    }
    if(colors.length<5){
      this.colors = colors;
      for(int i=colors.length; i<5; i++){
        this.colors.add(colors[colors.length-1]);
      }
      return;
    }
    this.colors = colors;
  }

  static dummy(){
    Color defaultColor = Colors.black54;
    List<Color> colors = [
      Colors.yellow,
    ];
    return StarColor(defaultColor:defaultColor,colors: colors);
  }
}


class RatingWidget extends StatefulWidget {
  final int initialRating = 5;
  final double starSize, starSpacing;
  final StarColor starColor;
  final OnRatingChange onRatingChange;

  const RatingWidget(
      {Key key,
      this.starSize = 24,
      this.starSpacing = 8,
      this.starColor,
      @required this.onRatingChange})
      : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int rating;
  StarColor starColor;
  @override
  void initState() {

    rating = widget.initialRating;
    if(widget.starColor==null){
      starColor=StarColor.dummy();
    }else{
      starColor = widget.starColor;
    }
    super.initState();
  }

  buildStar() {
    List<Widget> list = [];
    for (int i = 1; i < 6; i++) {
      list.add(InkWell(
        onTap: () {
          setState(() {
            rating = i;
          });
          widget.onRatingChange(i);
        },
        child: Icon(rating >= i ? MdiIcons.star : MdiIcons.starOutline,
            size: widget.starSize,
            color: rating >= i ? starColor.colors[rating-1] : starColor.defaultColor),
      ));
      if(i!=5){
        list.add(SizedBox(width: widget.starSpacing,));
      }

    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buildStar(),
      ),
    );
  }
}
