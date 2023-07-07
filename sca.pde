// segment length
float GraphLength = 20;
// delete distance
float killDiff = 40;
// search distsnce
float maxDiff = 60;
spaceColonization sc;

void setup()
{
  size(1024,600);
  background(255);
  strokeWeight(10);
  sc = new spaceColonization(new Vector2(width/2,0),height,50,width,10000);
  sc.draw();
}

void draw()
{
}

class Vector2
{
  float x;
  float y;
  Vector2(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
  float dist(Vector2 b) 
  {
    float xd = x - b.x;
    float yd = y - b.y;
    return xd * xd + yd * yd;
  }
  float abs()
  {
    return  sqrt(x * x + y * y);
  }
}

// define branch class
class Graph {
  Vector2 pos;
  Vector2 dir;
  
  int growCount;
  int index;
  IntList nearNodes;
  
  Graph(Vector2 p, Vector2 dir, int i){
    pos = p;
    this.dir = dir;
    index = i;
    growCount = 0;
    nearNodes = new IntList();
  }
  
  void setDIr(Node l){
    Vector2 Diff = diff(l.pos, pos);
    Diff = div(Diff, Diff.abs());
  }
  
  void drawLine()
  {
    line(pos.x, pos.y, pos.x + dir.x * GraphLength, pos.y + dir.y * GraphLength);
  }

  void reset()
  {
    growCount = 0;
    nearNodes = new IntList();
  }

  void append(int idx)
  {
    nearNodes.append(idx);
  }

  Vector2 Tip()
  {
    return Add(pos, product(dir, GraphLength));
  }
}

// defiine attr point class
class Node {
  Vector2 pos;
  float minDis;
  float maxDis;
  int nearestIdx;
  boolean arive;
  
  Node(Vector2 p, float a, float b)
  {
    arive = true;
    pos = p;
    nearestIdx = 0;
    minDis = a;
    maxDis = b;
  }
  
  void update(Graph b, ArrayList<Graph> list)
  {
    Graph Min = list.get(nearestIdx);
    if (Min.pos.dist(b.pos) <= minDis)
    {
      arive = false;
    }
    if (Min.pos.dist(pos) >= b.pos.dist(pos))
    {
      nearestIdx = b.index;
    }
  }

  void Draw()
  {
    fill(100,100,255,10);
    ellipse(pos.x, pos.y,maxDiff,maxDiff);
    fill(255);
    ellipse(pos.x, pos.y, killDiff, killDiff);
  }
}

class spaceColonization{
  Vector2 srt;
  float h,w_1,w_2;
  int nodesNum;
  ArrayList<Graph> graph;
  ArrayList<Node> nodes;
  
  spaceColonization(Vector2 s,float h,float w,float w2,int nn){
      srt = s;
      this.h = h;
      w_1 = w;
      w_2 = w2;
      nodesNum = nn;
      nodes = new ArrayList<Node>();
      graph = new ArrayList<Graph>();
      
      graph.add(new Graph(srt, new Vector2(0, 1), 0));
      start(h,w_2);
  }
  
  void draw(){
    for(int i = 0;i<graph.size();i++){
      graph.get(i).drawLine();
    }
  }
  
  void calclate(){
  }
  
  void start(float h,float w){
    for (int i=0; i<nodesNum; i++)
    {
      float lr =random(w) + srt.x - w/2 ;
      float tb = random(h);
      nodes.add(new Node(new Vector2(lr,tb),killDiff , maxDiff));
    }
    int nodeCount = 0;
    int prev = -1;
    boolean add = false;
    // calcurate while dont increase the number of segments
    while(nodeCount != prev){
      prev = nodeCount;
      println("run",nodeCount,prev);
      IntList nB = new IntList();
      for(int i=0;i<nodes.size();i++){
        float minDiff = 1000000;
        int minIndex = 0;
        boolean create = false;
        
        // search nearest segmet from each attr point
        for(int j= 0;j<graph.size();j++){
          float dist = diff(nodes.get(i).pos, graph.get(j).Tip()).abs();
          if(dist <= nodes.get(i).maxDis){
            if(minDiff > dist){
              minIndex = j;
              minDiff = dist;
              create = true;
              add = true;
            }
          }
        }
        
        // add attr point to nearest segment
        if(create){
          graph.get(minIndex).append(i);
          graph.get(minIndex).growCount++;
        if(graph.get(minIndex).growCount == 1)
          nB.append(minIndex);
        }
      }
      println("run",nB.size());
      
      // if can creat new segmet
      if(add)
        for (int i = 0; i<nB.size(); i++)
        {
          // calcurate new direction
          int idx = nB.get(i);
          Vector2 Dir = new Vector2(0, 0);
          for (int j = 0; j<graph.get(idx).nearNodes.size(); j++)
          {
            int ln = graph.get(idx).nearNodes.get(j);
            Vector2 Diff = diff(nodes.get(ln).pos, graph.get(idx).Tip());
            Dir = Add(Dir, div(Diff, Diff.abs()));
          }
          Dir = div(Dir, Dir.abs());
          
          // generate new segment
          graph.add(new Graph(graph.get(idx).Tip(), Dir, graph.size()));
          graph.get(idx).reset();
        } 
        
      // search points which shoud delete
      IntList deleteList = new IntList();
      for (int i=0; i<nodes.size(); i++)
      {
        for(int j = 0;j<graph.size();j++)
        {
          if(diff(nodes.get(i).pos,graph.get(j).pos).abs() <= nodes.get(i).minDis)
          {
            deleteList.append(i);
            break;
          }
        }
      }
      // delete attr point
      if(deleteList.size() > 0)
      {
        for(int i = deleteList.size()-1;i >= 0;i--)
        {
          nodes.remove(deleteList.get(i));
          nodeCount += 1;
        }
      }
    }
  }
}


// define vector functions
Vector2 Add(Vector2 a, Vector2 b)
{
  return new Vector2(a.x + b.x, a.y + b.y);
}

Vector2 diff(Vector2 a, Vector2 b)
{
  return new Vector2(a.x - b.x, a.y - b.y);
}

Vector2 product(Vector2 a, float b)
{
  return new Vector2(a.x * b, a.y * b);
}

Vector2 div(Vector2 a, float b)
{
  return new Vector2(a.x / b, a.y / b);
}
