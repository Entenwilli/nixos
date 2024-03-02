{ stdenv, fetchzip }:

stdenv.mkDerivation {
  name = "eclipse-dfa";
  src = fetchzip {
    url = "https://updatesite.palladio-simulator.com/DataFlowAnalysis/product/nightly/DataFlowAnalysis.linux.gtk.x86_64.zip";
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  };
}
