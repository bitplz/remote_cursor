enum MouseAction { move, click, doubleClick, rightClick }

extension MouseActionExtension on MouseAction {
  String get jsonValue {
    switch (this) {
      case MouseAction.move:
        return "move";
      case MouseAction.click:
        return "click";
      case MouseAction.doubleClick:
        return "double_click";
      case MouseAction.rightClick:
        return "right_click";
    }
  }
}

class MouseActionConfig {
  double dx;
  double dy;
  MouseAction mouseAction;

  Map<String, dynamic> get toJson => _toJson();

  MouseActionConfig({
    required this.dx,
    required this.dy,
    required this.mouseAction,
  });

  Map<String, dynamic> _toJson() {
    return {"dx": dx, "dy": dy, "action": mouseAction.jsonValue};
  }
}
