const Spatial = artifacts.require("Spatial");

contract("Spatial", async () => {
  let spatial;
  const polygon = [100,  110,
    130,  50,
    160,  150,
    180,  140,
    190,  30,
    240,  250,
    250,  240,
    290,  20,
    350,  50,
    370,  180,
    380,  190,
    390,  10,
    420,  10,
    430,  150,
    400,  200,
    360,  200,
    300,  260,
    250,  280,
    220,  240,
    200,  260,
    120,  240]
  ;

  const inside = [300, 120];
  const outside = [800, 120];


  before(async () => {
    spatial = await Spatial.deployed();
  }); 

  it('Should deploy smart Spatial properly', async() => {
      const spatial = await Spatial.deployed();
      assert(spatial.address !== '');
  });

  it("Should determine a correct point in polygon", async () => {
    const result = await spatial.pointInPolygon(inside, polygon);


    assert(result);
  });

  it("Should determine a correct point in polygon", async () => {
    const result = await spatial.pointInPolygon(outside, polygon);


    assert(!result);
  });

});