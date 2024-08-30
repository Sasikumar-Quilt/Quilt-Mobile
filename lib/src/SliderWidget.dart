import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
final List<String> imgList = [
  'assets/images/content1.json',
  'assets/images/content2.json',
  'assets/images/content3.json',
];
class SliderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SliderPageState();
  }
}
class SliderPageState extends State<SliderPage>{
  int _current = 0;
  final CarouselController _controller = CarouselController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  final List<Widget> imageSliders = imgList
      .map((item) => Container(
    child: Container(
      margin: EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Lottie.asset(item),
            ],
          )),
    ),
  ))
      .toList();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: InkWell(
        child: Icon(
          Icons.keyboard_arrow_left,
          color: Color(0xFF8C8CA1),
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    ),body: Column(children: [
      Expanded(
        child: CarouselSlider(
          items: imageSliders,
          carouselController: _controller,
          options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imgList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12.0,
              height: 12.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4)),
            ),
          );
        }).toList(),
      ),
    ]),));
  }

}