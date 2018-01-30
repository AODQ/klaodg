import std.string : format;
import klaodg;

void main() {
  Initialize(640, 480, "klaodg testing bed", (GLBuffer img, float time) {
    imguiLabel("Time: %s seconds".format(time));

    foreach ( i; 0 .. 640 )
    foreach ( j; 0 .. 480 ) {
      float2 pos = To_Vec!float2([i, j]);
      float4 col = float4(pos.x/640.0f, pos.y/480.0f, sin(time), 1.0f);
      img.Apply(To_Vec!int2(pos), col);
    }
  });
}
