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

# Tested under 64 bit Lazarus. Needs tests under 32 bit Lazarus and 32/64 bit Delphi
