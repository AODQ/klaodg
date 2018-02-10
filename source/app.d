import std.string : format;
import std.parallelism, std.range;
import klaodg;
import sdf;

immutable int2   dim    = int2(256, 144);
immutable float2 dim_fl = To_Vec!float2(dim);

void main() {
  Initialize(256, 144, "klaodg testing bed", (GLBuffer img, float time) {
    immutable float3 Lo = float3(sin(time)*64.0f, cos(time)*64.0f, sin(time)+cos(time));

    immutable float3 eye = float3(4.5f, 5.0f+sin(time)*2.0f, 16.0f);

    foreach ( i; iota(0, dim.x).parallel )
    foreach ( j; iota(0, dim.y) ) {
      int2 pos = To_Vec!int2([i, j]);
      float2 puv = -1.0f + 2.0f*(To_Vec!float2(pos)/dim_fl);
      puv.x *= dim_fl.x/dim_fl.y;

      auto ray = Look_At(puv, eye, float3(0.0f));
      float t = March!(16, 128.5f)(ray);

      float3 col = float3(0.0f);
      if ( t >= 0.0f ) {
        col = float3(dot(Normalize(eye-Lo),Normal(ray.ori + ray.dir*t)));
      }

      img.Apply(To_Vec!int2(pos), float4(col, 1.0f));
    }
  });
}
