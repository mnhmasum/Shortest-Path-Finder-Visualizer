import 'dart:math';
import 'package:dijkshortpath/coordinate.dart';
import 'package:dijkshortpath/node.dart';
import 'package:dijkshortpath/utlity/utlity.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _radioValue1 = 0;
  int startIndex = 0;
  int endIndex = 99;
  bool pathBlinkAnimation = false;

  GlobalKey gridKey = new GlobalKey();
  List<Adjacent> visited = new List<Adjacent>();
  List<Adjacent> node = new List<Adjacent>();
  List<int> path = new List<int>();

  List<List<int>> direction = [
    [-1, 0],
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 1],
    [1, 1],
    [1, -1],
    [-1, -1]
  ];
  List<List<String>> gridState = [
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", ""],
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildBody() {
    int gridStateLength = gridState.length;

    return Column(children: <Widget>[
      AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: GridView.builder(
            key: gridKey,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridStateLength,
              //childAspectRatio: 8.0 / 11.9
            ),
            itemBuilder: _buildGridItems,
            itemCount: gridStateLength * gridStateLength,
          ),
        ),
      ),
    ]);
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int gridStateLength = gridState.length;
    int x, y = 0;
    x = (index / gridStateLength).floor();
    y = (index % gridStateLength);
    GlobalKey gridItemKey = new GlobalKey();

    return GestureDetector(
      onTapDown: (details) {
        selectItemOnTap(gridItemKey, details);
      },
      onVerticalDragUpdate: (details) {
        _selectItem(gridItemKey, details);
      },
      onHorizontalDragUpdate: (details) {
        _selectItem(gridItemKey, details);
      },
      child: GridTile(
        key: gridItemKey,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5)),
          child: Center(
            child: _buildGridItem(x, y),
          ),
        ),
      ),
    );
  }

  void selectItemOnTap(
      GlobalKey<State<StatefulWidget>> gridItemKey, TapDownDetails details) {
    RenderBox _box = gridItemKey.currentContext.findRenderObject();
    RenderBox _boxGrid = gridKey.currentContext.findRenderObject();
    Offset position =
        _boxGrid.localToGlobal(Offset.zero); //this is global position
    double gridLeft = position.dx;
    double gridTop = position.dy;

    double gridPosition = details.globalPosition.dy - gridTop;

    //Get item position
    int indexX = (gridPosition / _box.size.width).floor().toInt();
    int indexY = ((details.globalPosition.dx - gridLeft) / _box.size.width)
        .floor()
        .toInt();

    if (_radioValue1 == 0) {
      _radioValue1 = 1;
      gridState[indexX][indexY] = "S";
      startIndex = Utility.coordinateToIndex(indexX, indexY);
    } else if (_radioValue1 == 1) {
      _radioValue1 = 2;
      gridState[indexX][indexY] = "E";
      endIndex = Utility.coordinateToIndex(indexX, indexY);
    } else if (_radioValue1 == 2) {
      if (gridState[indexX][indexY] == "C") {
        gridState[indexX][indexY] = "";
      } else {
        gridState[indexX][indexY] = "C";
      }
    }

    setState(() {});
  }

  Widget _buildGridItem(int x, int y) {
    switch (gridState[x][y]) {
      case '':
        return Text('');
        break;
      case 'Y':
        return Container(
          color: Colors.grey,
        );
        break;
      case 'S':
        return Container(
          color: Colors.blue,
        );
        break;
      case 'E':
        return Container(
          color: Colors.red,
        );
        break;
      case 'P':
        return Container(
          color: Colors.blueGrey,
        );
        break;
      case 'N':
        return Container(
          color: Colors.white,
        );
        break;
      case 'R':
        return Container(
          color: Colors.yellow,
        );
      case 'C':
        return Container(
          color: Colors.black,
        );
        break;
      default:
        return Text(gridState[x][y].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            _buildBody(),
            Expanded(child: SizedBox()),
            _buildRadioControls(),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Container _buildRadioControls() {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: Row(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Radio(
                      value: 0,
                      groupValue: _radioValue1,
                      onChanged: _handleRadioValueChange,
                    ),
                    SizedBox(width: 2),
                    Text("Select Start", style: TextStyle(fontSize: 16))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: _radioValue1,
                      onChanged: _handleRadioValueChange,
                    ),
                    SizedBox(width: 2),
                    Text("Select Stop", style: TextStyle(fontSize: 16))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                      value: 2,
                      groupValue: _radioValue1,
                      onChanged: _handleRadioValueChange,
                    ),
                    SizedBox(width: 2),
                    Text("Select Block", style: TextStyle(fontSize: 16))
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 24,
          ),
          RaisedButton(
            onPressed: () {
              Coordinate coordinate = Utility.getXY(startIndex);
              _adjacent(coordinate.x, coordinate.y);
            },
            child: Text('START', style: TextStyle(fontSize: 20)),
            color: Colors.blue,
            textColor: Colors.white,
            elevation: 5,
          ),
          SizedBox(
            width: 16,
          ),
          RaisedButton(
            onPressed: () {
              reset();
            },
            child: Text('RESET', style: TextStyle(fontSize: 20)),
            color: Colors.blue,
            textColor: Colors.white,
            elevation: 5,
          ),
        ],
      ),
    );
  }

  void reset() {
    for (int i = 0; i < gridState.length; i++) {
      for (int j = 0; j < gridState[i].length; j++) {
        gridState[i][j] = "";
      }
    }
    startIndex = 0;
    endIndex = 0;
    _radioValue1 = 0;
    pathBlinkAnimation = false;
    visited.clear();
    node.clear();
    path.clear();
    setState(() {});
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  void _selectItem(GlobalKey<State<StatefulWidget>> gridItemKey, var details) {
    RenderBox _boxItem = gridItemKey.currentContext.findRenderObject();
    RenderBox _boxMainGrid = gridKey.currentContext.findRenderObject();
    Offset position =
        _boxMainGrid.localToGlobal(Offset.zero); //this is global position
    double gridLeft = position.dx;
    double gridTop = position.dy;

    double gridPosition = details.globalPosition.dy - gridTop;

    //Get item position
    int rowIndex = (gridPosition / _boxItem.size.width).floor().toInt();
    int colIndex =
        ((details.globalPosition.dx - gridLeft) / _boxItem.size.width)
            .floor()
            .toInt();

    if (_radioValue1 == 2) {
      if (gridState[rowIndex][colIndex] != "E" ||
          gridState[rowIndex][colIndex] != "S") {
        gridState[rowIndex][colIndex] = "C";
      }
    }

    setState(() {});
  }

  bool _checkValid(int row, int col) {
    if (row >= 0 && row <= 9 && col >= 0 && col <= 9) {
      if (gridState[row][col] == "C") {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<void> _adjacent(int row, int col) async {
    if (_checkValid(row, col)) {
      if (node.isNotEmpty) {
        node[0].visited = true;
        Coordinate coordinate = Utility.getXY(node[0].vertexIndex);
        row = coordinate.x;
        col = coordinate.y;
        if (gridState[row][col] != "S" && gridState[row][col] != "E") {
          gridState[row][col] = "P";
        }
        print(gridState);
      } else {
        int index = (row * 10) + col;
        if (gridState[row][col] != "S" && gridState[row][col] != "E") {
          gridState[row][col] = "P";
        }
        Adjacent adjacent = new Adjacent();
        adjacent.visited = true;
        adjacent.vertexDistance = 0;
        adjacent.previousVertexIndex = index;
        adjacent.vertexIndex = index;
        node.add(adjacent);
      }
    }

    for (int i = 0; i < direction.length; i++) {
      int x = direction[i][0];
      int y = direction[i][1];

      if (_checkValid(row + x, col + y)) {
        if (gridState[row + x][col + y] == "P") {
        } else if (gridState[row + x][col + y] == "Y") {
          updateVertexDistance(row, x, col, y);
        } else {
          if (gridState[row + x][col + y] != "S" &&
              gridState[row + x][col + y] != "E") {
            gridState[row + x][col + y] = "Y";
          }

          Adjacent adjacent = new Adjacent();
          adjacent.visited = false;
          double dist = _getDistance(row, col, row + x, col + y);
          adjacent.vertexDistance = dist.floor().toDouble();
          adjacent.previousVertexIndex = Utility.coordinateToIndex(row, col);
          adjacent.vertexIndex = Utility.coordinateToIndex(row + x, col + y);
          node.add(adjacent);
        }
      }
    }

    if (node.isNotEmpty) {
      visited.add(node[0]);
      node.removeAt(0);
      node.sort((a, b) => a.vertexDistance.compareTo(b.vertexDistance));
      setState(() {});

      Coordinate startCoordinate = Utility.getXY(startIndex);
      Coordinate endCoordinate = Utility.getXY(endIndex);

      if (row == endCoordinate.x && col == endCoordinate.y) {
        int index = Utility.coordinateToIndex(row, col);
        if (index == endIndex) {
          _getPath(endIndex);
          print("Short Path is: $path");
          pathBlinkAnimation = true;
          while (pathBlinkAnimation) {
            _drawPath(startCoordinate, endCoordinate);
            await Future.delayed(const Duration(milliseconds: 500));
            _drawPathColor(startCoordinate, endCoordinate);
            await Future.delayed(const Duration(milliseconds: 500));
          }
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      int index = node[0].vertexIndex;
      Coordinate coordinate = Utility.getXY(index);
      _adjacent(coordinate.x, coordinate.y);
    }
  }

  void updateVertexDistance(int row, int x, int col, int y) {
    Adjacent adjacent = node.firstWhere(
        (n) => n.vertexIndex == Utility.coordinateToIndex(row + x, col + y));
    double afterIncrease =
        _getDistance(row, col, row + x, col + y).floor().toDouble() +
            node[0].vertexDistance;
    if (afterIncrease < adjacent.vertexDistance) {
      adjacent.vertexDistance = afterIncrease.floor().toDouble();
      adjacent.previousVertexIndex = Utility.coordinateToIndex(row, col);
    }
  }

  void _drawPath(Coordinate startCoord, Coordinate endCoord) {
    if (pathBlinkAnimation) {
      for (int p in path) {
        Coordinate coordinate = Utility.getXY(p);
        gridState[coordinate.x][coordinate.y] = "R";
      }
      if (pathBlinkAnimation) {
        gridState[startCoord.x][startCoord.y] = "S";
        gridState[endCoord.x][endCoord.y] = "E";
        setState(() {});
      }
    }
  }

  void _drawPathColor(Coordinate startCoord, Coordinate endCoord) {
    if (pathBlinkAnimation) {
      for (int p in path) {
        Coordinate coordinate = Utility.getXY(p);
        gridState[coordinate.x][coordinate.y] = "";
      }
      gridState[startCoord.x][startCoord.y] = "S";
      gridState[endCoord.x][endCoord.y] = "E";
      setState(() {});
    }
  }

  double _getDistance(int row, int col, int row1, int col1) =>
      sqrt(pow((row - row1), 2) + pow((col - col1), 2));

  Future<bool> _getPath(int index) async {
    int prev = 0;
    for (var last in visited) {
      if (last.vertexIndex == index) {
        prev = last.previousVertexIndex;
        print(prev);
        break;
      }
    }

    path.add(prev);
    if (prev == startIndex) {
      return false;
    }
    return _getPath(prev);
  }
}
