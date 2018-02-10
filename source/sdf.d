module sdf;
import klaodg;

auto length(T)(T v) pure nothrow { return v.magnitude; }
struct Ray { float3 ori, dir; }

private float sdSphere ( float3 origin, float radius ) pure nothrow {
  return (origin).magnitude - radius;
}

private float sdTorus ( float3 p, float2 t ) pure nothrow {
  float2 q = float2(length(p.xz) - t.x, p.y);
  return length(q)-t.y;
}

float3 Max ( float3 t, float u ) pure nothrow {
  import std.algorithm : max;
  return float3(max(t.x, u), max(t.y, u), max(t.z, u));
}

void Union ( ref float t, float d) pure nothrow {
  if ( t > d ) t = d;
}

float sdBox    ( float3 o, float3 b ) pure nothrow {
  import std.math : fabs;
  import std.algorithm : min, max;
  float3 d = float3(fabs(o.x), fabs(o.y), fabs(o.z)) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0f) + length(Max(d, 0.0f));
}

void opRotate(string unit)( ref float3 op, float a ) {
  import std.string : format;
  mixin(q{float2 p = float2(op.%s, op.%s);}.format(unit[0], unit[1]));
  auto res = cos(a)*p + sin(a)*float2(p.y, -p.x);
  mixin(q{op.%s = res.x;}.format(unit[0]));
  mixin(q{op.%s = res.y;}.format(unit[1]));
}

float Map ( float3 o ) pure nothrow {
  //--light--
  float res = sdBox(o-float3(0.0f, 2.98f, 0.0f), float3(0.5f, 0.02f, 0.5));

  //-----------wall--------
  // left/right
  Union(res, sdBox(o-float3( 3.0f,  0.0f,  0.0f), float3(0.01f, 3.00f, 3.00f)));
  Union(res, sdBox(o-float3(-3.0f,  0.0f,  0.0f), float3(0.01f, 3.00f, 3.00f)));
  // up/down
  Union(res, sdBox(o-float3( 0.0f,  3.0f,  0.0f), float3(3.00f, 0.01f, 3.00f)));
  Union(res, sdBox(o-float3( 0.0f, -3.0f,  0.0f), float3(3.00f, 0.01f, 3.00f)));
  // back
  Union(res, sdBox(o-float3( 0.0f,  0.0f, -3.0f), float3(3.00f, 3.00f, 0.01f)));
  //-----------boxes--------
  // // -- left box
  // float3 to = o-float3(1.5f, -1.0f, -0.5f);
  // to.xy = float2(0.5f);
  // opRotate!"xz"(to, (3.141592654f)*0.09f);
  // Union(res, sdBox(to, float3(1.0f, 2.0f, 0.6f)));
  // // -- right box
  // to = o-float3(-0.8f, -2.0f, 1.5f);
  // opRotate!"xz"(to, -(3.141592654f)*0.19f);
  // Union(res, sdBox(to, float3(1.0f, 1.0f, 0.6f)));
  return res;
}

float3 Normal ( float3 p ) pure nothrow {
  float2 e = float2(1.0f, -1.0f)*0.5883f*0.0005f;
  return Normalize(
    e.xyy*Map(p + e.xyy) +
    e.yyx*Map(p + e.yyx) +
    e.yxy*Map(p + e.yxy) +
    e.xxx*Map(p + e.xxx));
}

Ray Look_At ( float2 uv, float3 eye, float3 center,
              float3 up = float3(0.0f, 1.0f, 0.0f)) pure nothrow {
  float3 ww = Normalize(center - eye),
         uu = Normalize(cross(up, ww)),
         vv = Normalize(cross(ww, uu));
  return Ray(eye, Normalize(uv.x*uu + uv.y*vv + 2.5*ww));
}

float March(int Reps, float Dist)(Ray ray) {
  float distance = 0.0f;
  foreach ( i; 0 .. Reps ) {
    float dist = Map(ray.ori + ray.dir*distance);
    if ( dist <= 0.001f ) return distance;
    if ( dist > Dist ) return -1.0f;
    distance += dist;
  }
  import std.stdio;
  return -1.0f;
}
