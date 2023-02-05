{ lib, stdenv, writeShellScriptBin
, glib
, curlWithGnuTls
, SDL2
, requireFile
}:

let
  wrapper = writeShellScriptBin "dstd" ''
    dir=$(dirname "$0")
    cd $dir
    exec ./dontstarve_dedicated_server_nullrenderer_x64 "$@"
  '';
in
stdenv.mkDerivation rec {
  pname = "dontstarvetogether-headless";
  version = "1.0";

  src = ./src ;

  buildInputs = [ glib ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  libPaths = lib.makeLibraryPath [ curlWithGnuTls glib stdenv.cc.cc.lib stdenv.cc.libc (SDL2.override {
    waylandSupport = false;
    x11Support = false;
    libGLSupported = false;
    drmSupport = false;
    pipewireSupport = false;
    pulseaudioSupport = false;
  }) ];

  installPhase = ''
    mkdir $out
    cp -R bin64 $out/bin
    cp -R mods $out/
    cp -R data $out/
    cp -p version.txt $out/

    rm $out/bin/lib64/libSDL2-2.0.so.0
    rm -r $out/bin/scripts
    rm $out/bin/dontstarve
    mv $out/bin/lib64 $out/lib

    echo "" >> $out/mods/modsettings.lua
    for f in $(find steamapps/workshop/content/322330/ -maxdepth 1 -mindepth 1 -type d)
    do
      bname=$(basename "$f")
      echo "installing workshop id $bname"
      cp -r "$f" $out/mods/workshop-$bname
      echo "ForceEnableMod(\"$bname\")" >> $out/mods/modsettings.lua
    done

    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${libPaths}:$out/lib \
      $out/bin/dontstarve_dedicated_server_nullrenderer_x64

    for f in "lib/*.so"
    do
      echo patching $f
      echo $libPaths
      patchelf \
        --set-rpath ${libPaths}:$out/lib \
        $out/$f
    done
    cp -p ${wrapper}/bin/dstd $out/bin
  '';

  meta = with lib; {
    homepage = "https://apitrace.github.io";
    description = "Don't Starve Together Deadicated server";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
