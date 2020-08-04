# page_entry_animation

Flutter 页面进场动画，支持从左往右、从右往左、从上往下以及从下往上。从右往左和从下往上的页面，在安卓上也支持类似 IOS 左侧滑动推出。

## 从右往左(R2L)
![image](https://s1.ax1x.com/2020/08/04/a0CoUf.gif)

## 从左往右(L2R)
![image](https://s1.ax1x.com/2020/08/04/a0C4bt.gif)

## 从下往上(B2T)
![image](https://s1.ax1x.com/2020/08/04/a0CIVP.gif)

## 从上往下(T2B)
![image](https://s1.ax1x.com/2020/08/04/a0PwRg.gif)

## Widget 参数：

| Parameter       | Type                   | Default                    | Description                                                                     |
| --------------- | ---------------------- | -------------------------- | ------------------------------------------------------------------------------- |
| widget          | Widget                 | null                       | 传入的页面 Widget                                                               |
| type            | PageEntryAnimationType | PageEntryAnimationType.R2L | 渲染类型，默认从右往左加载                                                      |
| backgroundColor | Color                  | null                       | 侧滑退出的背景蒙层颜色                                                          |
| needSlideOut    | bool                   | true                       | 是否需要左侧滑动退出，默认 true。从上往下(T2B)，从左往右(L2R)类型不支持侧滑退出 |

## 调用示例：

```Dart
 Navigator.of(context).push(PageEntryAnimation(
                  ContainerTest(),
                  backgroundColor: Colors.red,
                  needSlideOut: true,
                  type: PageEntryAnimationType.R2L))
```
