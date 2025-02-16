# AVIF and HEIC for Delphi, Free Pascal/Lazarus

Read &amp; write AVIF and HEIC images in Delphi, Free Pascal and Lazarus

Requires .DLL files (included). For Linux and MacOS you need to download binaries from libheif project.

## Usage examples

### Using TImage / TPicture

    Image1.Picture.LoadFromFile('test.heic');
    Image1.Picture.LoadFromFile('test.avif');

### Using classes directly

    var a: TAvifImage;
        h: THeicImage;
    begin
      Image1.Picture.LoadFRomFile('test.bmp');

      a := TAvifImage.Create;
      a.Assign(Image1.Picture.Bitmap);
      a.SaveToFile('test1.avic');
      a.free;

      h := THeicImage.Create;
      h.Assign(Image1.Picture.Bitmap);
      h.SaveToFile('test1.heic');
      h.free;
    end;

# Tested under 64 bit Lazarus and 64 bit Delphi 12.

Should work under other 64 bit Delphis.
Needs tests under 32 bit Lazarus and 32 bit Delphi.

## This unit uses libheif.DLL

The libheif is distributed under the terms of the GNU Lesser General Public License. 
Copyright (c) 2017-2020 Struktur AG
Copyright (c) 2017-2024 Dirk Farin
Contact: Dirk Farin dirk.farin@gmail.com

## Linux (Debian, Ubuntu, Mint)

1) apt install apt-file libheif-dev
2) apt-file search libheif.so
It will list you how your liblz4.so files are named *exactly* and where they are
3) Open HeifImage.pas and edit "const LIBHEIF"
4) Change the value of that const. Enter filename (excluding path) found in step 2
5) Compile and run
