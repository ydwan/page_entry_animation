import 'package:flutter/material.dart';

/// 动画路由
class AnimationRoute extends PageRouteBuilder {
  final Widget widget;
  final AnimationRouteType type;
  final Color backgroundColor;
  // 是否需要侧滑退出，默认需要
  final bool needSlideOut;

  AnimationRoute(this.widget,
      {this.type, this.backgroundColor, this.needSlideOut})
      : super(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 500), //设置动画时长500毫秒
            pageBuilder: (BuildContext context, Animation<double> animation1,
                Animation<double> animation2) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              Tween<Offset> tween;
              switch (type) {
                case AnimationRouteType.T2B:
                  tween = Tween<Offset>(
                      begin: Offset(0.0, -1.0), end: Offset(0.0, 0.0));
                  break;
                case AnimationRouteType.B2T:
                  tween = Tween<Offset>(
                      begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0));
                  break;
                case AnimationRouteType.L2R:
                  tween = Tween<Offset>(
                      begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0));
                  break;
                case AnimationRouteType.R2L:
                default:
                  tween = Tween<Offset>(
                      begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0));
                  break;
              }
              Color color = Color.fromRGBO(0, 0, 0, 0);
              if (backgroundColor != null) {
                color = backgroundColor;
              }
              //左右滑动
              return new RoutePage(
                child: child,
                backgroundColor: color,
                type: type,
                needSlideOut: needSlideOut,
                animate: tween.animate(CurvedAnimation(
                    parent: animation1, curve: Curves.fastOutSlowIn)),
              );
            });
}

class RoutePage extends StatefulWidget {
  final Color backgroundColor;
  final AnimationRouteType type;
  final Animation<Offset> animate;
  // 是否需要侧滑退出，默认true
  final bool needSlideOut;
  final Widget child;
  RoutePage(
      {this.backgroundColor,
      @required this.animate,
      @required this.child,
      this.needSlideOut,
      this.type});

  @override
  RoutePageState createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> position;
  double positionPercent;

  bool isMove = false;
  bool isClose = false;
  bool needSlideOut = true;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器，这里限定动画时常为200毫秒
    controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    this.positionPercent = 0;
    this.position = widget.animate;
    // 如果是从上往下、或者从左往右加载的页面，不允许它们有侧滑关闭事件，感觉用户体验特别怪异
    if (widget.type == AnimationRouteType.T2B ||
        widget.type == AnimationRouteType.L2R) {
      this.needSlideOut = false;
    }
  }

  void changeOffset(DragUpdateDetails details) {
    Size size = MediaQuery.of(context).size;
    Offset localPosition = details.localPosition;
    // 系数比例，因为是左侧滑动，那么从上往下或者从下往上会出现滑动用户体验比较差
    // 所以当上下类型时，给定它们的比例为1.3， 加大滑动退出距离
    double ratio;
    double percent;
    Tween<Offset> tween;
    switch (widget.type) {
      case AnimationRouteType.T2B:
      case AnimationRouteType.B2T:
        ratio = 1.3;
        percent = localPosition.dx / size.width * ratio;
        tween = Tween<Offset>(
            begin: Offset(0.0, percent), end: Offset(0.0, percent));
        break;
      case AnimationRouteType.L2R:
      case AnimationRouteType.R2L:
      default:
        ratio = 1;
        percent = localPosition.dx / size.width * ratio;
        tween = Tween<Offset>(
            begin: Offset(percent, 0.0), end: Offset(percent, 0.0));
        break;
    }
    setState(() {
      this.positionPercent = percent;
      this.position = tween.animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
      // 是否需要关闭的位置
      double closePosition = size.width * 0.55 / ratio;
      if (localPosition.dx >= closePosition) {
        isClose = true;
      } else {
        isClose = false;
      }
    });
  }

  void logout() {
    Tween<Offset> tween;
    switch (widget.type) {
      case AnimationRouteType.T2B:
      case AnimationRouteType.B2T:
        tween = Tween<Offset>(
            begin: Offset(0.0, this.positionPercent), end: Offset(0.0, 1));
        break;
      case AnimationRouteType.L2R:
      case AnimationRouteType.R2L:
      default:
        tween = Tween<Offset>(
            begin: Offset(this.positionPercent, 0.0), end: Offset(1, 0.0));
        break;
    }
    this.position = tween.animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    this.controller.forward()
      ..then((value) {
        Navigator.pop(context);
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: widget.backgroundColor,
      child: SlideTransition(
        position: this.position,
        child: GestureDetector(
          onHorizontalDragStart: (details) {
            Size size = MediaQuery.of(context).size;
            Offset localPosition = details.localPosition;
            // 是否可以滑动的起始位置
            double canMovePosition = size.width * 0.1;
            if (localPosition.dx <= canMovePosition) {
              setState(() {
                this.isMove = true;
              });
            }
          },
          onHorizontalDragUpdate: (details) {
            if (isMove && this.needSlideOut) {
              changeOffset(details);
            }
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              // 如果不是拉到阈值退出当前页，则让它还原初始位置
              if (this.isClose == false) {
                this.position = widget.animate;
              } else {
                logout();
              }
              this.isMove = false;
            });
          },
          child: Container(
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    offset: Offset(5.0, 5.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0)
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

enum AnimationRouteType {
  // 从左往右进入
  L2R,
  // 从右往左
  R2L,
  // 从上往下
  T2B,
  // 从下往上
  B2T
}
