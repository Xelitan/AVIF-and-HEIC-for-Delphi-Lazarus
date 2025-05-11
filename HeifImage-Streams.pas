unit HeifImage;

{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:	Reader and writer for AVIF and HEIC images                    //
// Version:	0.6                                                        //
// Date:	01-MAR-2025                                                   //
// License:     MIT                                                           //
// Target:	Win64, Free Pascal, Delphi                                    //
// Copyright:	(c) 2025 Xelitan.com.                                         //
//		All rights reserved.                                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses Classes, Graphics, SysUtils, Math, Types, Dialogs;

const LIBHEIF = 'libheif.dll';

{$IFNDEF FPC}type PtrUInt = UIntPtr;{$ENDIF}

type
  THeifCompression = (
     compression_undefined = 0,
     // HEVC, same as H.256
     compression_HEVC = 1,
     // AVC (unused)
     compression_AVC = 2,
     // JPEG
     compression_JPEG = 3,
     // AVIF
     compression_AV1 = 4,
     // VVC (unused)
     compression_VVC = 5,
     // EVC (unused)
     compression_EVC = 6,
     // JPEG 2000
     compression_JPEG2000 = 7,
     // uncompressed
     compression_uncompressed = 8,
     // image mask
     compression_mask = 0
     );

  THeifProgressStep = (  
     heif_progress_step_total = 0,
     heif_progress_step_load_tile = 1
     );
  THeifChromaDownsamplingAlgorithm = (
    heif_chroma_downsampling_nearest_neighbor = 1,
    heif_chroma_downsampling_average = 2,
    heif_chroma_downsampling_sharp_yuv = 3
  );
  THeifChromaUpsamplingAlgorithm =
  (
    heif_chroma_upsampling_nearest_neighbor = 1,
    heif_chroma_upsampling_bilinear = 2
  );
  THeifColorConversionOptions = record
    version: Byte; //must be 1
    preferred_chroma_downsampling_algorithm: THeifChromaDownsamplingAlgorithm;
    preferred_chroma_upsampling_algorithm: THeifChromaUpsamplingAlgorithm;
    only_use_preferred_chroma_algorithm: Byte;
  end;

  THeifReadingOptions = Pointer;
  PHeifEncoder = Pointer;
  THeifEncodingOptions = Pointer;

  THeifDecodingOptions = record
    version: Byte;
    //v1 options:
    ignore_transformations: Byte;  // 0 or 1
    start_progress: procedure(step: THeifProgressStep; max_progress: Integer; progress_user_data: Pointer); cdecl;
    on_progress: procedure(step: THeifProgressStep; progress: Integer; progress_user_data: Pointer); cdecl;
    end_progress: procedure(step: THeifProgressStep; progress_user_data: Pointer); cdecl;
    progress_user_data: Pointer;
    //v2 options
    convert_hdr_to_8bit: Byte;  //0 or 1
    //v3 options
    strict_decoding: Byte;  //0 or 1
    //v4 options
    decoder_id: PAnsiChar;
    //v5 options
    color_conversion_options: THeifColorConversionOptions;
    //v6 options
    cancel_decoding: function(progress_user_data: Pointer): Integer; cdecl;
  end;

  PHeifDecodingOptions = ^THeifDecodingOptions;
  PHeifImageHandle = Pointer;
  PPHeifImageHandle = ^PHeifImageHandle;
  PHeifImage = Pointer;

  THeifChannel = (
    heif_channel_Y           = 0,
    heif_channel_Cb          = 1,
    heif_channel_Cr          = 2,
    heif_channel_R           = 3,
    heif_channel_G           = 4,
    heif_channel_B           = 5,
    heif_channel_Alpha       = 6,
    heif_channel_interleaved = 10
    );
  THeifColorspace = (
    heif_colorspace_undefined = 99,
    heif_colorspace_YCbCr = 0,
    heif_colorspace_RGB = 1,
    heif_colorspace_monochrome = 2
    );
  THeifChroma = (
    heif_chroma_undefined = 99,
    heif_chroma_monochrome = 0,
    heif_chroma_420 = 1,
    heif_chroma_422 = 2,
    heif_chroma_444 = 3,
    heif_chroma_interleaved_RGB = 10,
    heif_chroma_interleaved_RGBA = 11,
    // HDR
    heif_chroma_interleaved_RRGGBB_BE = 12,
    heif_chroma_interleaved_RRGGBBAA_BE = 13,
    heif_chroma_interleaved_RRGGBB_LE = 14,
    heif_chroma_interleaved_RRGGBBAA_LE = 15
    );

  THeifError = record
    code: Integer;
    subcode: Integer;
    message: PAnsiChar;
  end;

  THeifString = PAnsiChar;

  THeifContextClass = TObject;
  THeifImageClass = TObject;
  THeifPixelImageClass = TObject;

  THeifContext = record
    context: THeifContextClass;
  end;
  PHeifContext = ^THeifContext;

  THeifWriteFunc = function(ctx: PHeifContext; const data: Pointer; size: PtrUInt; userdata: Pointer): THeifError;
  PHeifWriteFunc = ^THeifWriteFunc;

  THeifWriter = record
    writer_api_version: integer;
    write: THeifWriteFunc;
  end;
  PHeifWriter = ^THeifWriter;

  function heif_context_alloc: PHeifContext; cdecl; external LIBHEIF;
  function heif_context_encode_image(context: PHeifContext; image: PHeifImage; Encoder: PHeifEncoder; options: THeifEncodingOptions; out_image_handle: PPHeifImageHandle): THeifError;  cdecl; external LIBHEIF;
  function heif_context_get_encoder_for_format(context: PHeifContext; format: Integer; var Encoder: PHeifEncoder): THeifError;  cdecl; external LIBHEIF;
  function heif_context_get_primary_image_handle(context: PHeifContext; var out_image_handle: PHeifImageHandle): THeifError; cdecl; external LIBHEIF;
  function heif_context_read_from_file(context: PHeifContext; const filename: PAnsiChar; const options: Pointer): THeifError; cdecl; external LIBHEIF;
  function heif_context_read_from_memory_without_copy(context: PHeifContext; mem: PByteArray; size_t: PtrUInt; const readoptions: THeifReadingOptions): THeifError; cdecl; external LIBHEIF;
  function heif_context_write(context: PHeifContext; var writer: THeifWriter; userdata: Pointer): THeifError;  cdecl; external LIBHEIF;
  function heif_decode_image(handle: PHeifImageHandle; var out_image: PHeifImage; colorspace: Integer; chroma: Integer; options: Pointer): THeifError; cdecl; external LIBHEIF;
  function heif_decoding_options_alloc: PHeifDecodingOptions; cdecl; external LIBHEIF;
  function heif_encoder_release(encoder: PHeifEncoder): THeifString;  cdecl; external LIBHEIF;
  function heif_encoder_set_lossless(encoder: PHeifEncoder; enable: Longbool): THeifError; cdecl; external LIBHEIF;
  function heif_encoder_set_lossy_quality(encoder: PHeifEncoder; quality: integer): THeifError;  cdecl; external LIBHEIF;
  function heif_get_version: PAnsiChar; cdecl; external LIBHEIF;
  function heif_image_add_plane(image: PHeifImage; channel: Integer; width: integer; height: integer; bitDepth: integer): THeifError; cdecl; external LIBHEIF;
  function heif_image_create(width: integer; height: integer; colorspace: Integer; chroma: Integer; var image: PHeifImage): THeifError; cdecl; external LIBHEIF;
  function heif_image_get_plane(image: PHeifImage; channel: Integer; var stride: Integer): PByte;  cdecl; external LIBHEIF;
  function heif_image_handle_get_height(handle: PHeifImageHandle): Integer; cdecl; external LIBHEIF;
  function heif_image_handle_get_width(handle: PHeifImageHandle): Integer; cdecl; external LIBHEIF;
  function heif_image_handle_has_alpha_channel(handle: PHeifImageHandle): Longbool; cdecl; external LIBHEIF;
  procedure heif_context_free(context: PHeifContext); cdecl; external LIBHEIF;
  procedure heif_decoding_options_free(options: PHeifDecodingOptions); cdecl; external LIBHEIF;
  procedure heif_image_handle_release(handle: PHeifImageHandle); cdecl; external LIBHEIF;
  procedure heif_image_release(image: PHeifImage); cdecl; external LIBHEIF;

  { THeicImage }
type
  THeicImage = class(TGraphic)
  private
    IsHeic: Boolean;
    FBmp: TBitmap;
    FCompression: Integer;
    procedure DecodeFromStream(Str: TStream);
    procedure EncodeToStream(Str: TStream);
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
  //    function GetEmpty: Boolean; virtual; abstract;
    function GetHeight: Integer; override;
    function GetTransparent: Boolean; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetTransparent(Value: Boolean); override;
    procedure SetWidth(Value: Integer);override;
  public
    procedure SetLossyCompression(Value: Cardinal);
    procedure SetLosslessCompression;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    constructor Create; override;
    destructor Destroy; override;
    function ToBitmap: TBitmap;
  end;

  { TAvifImage }

  TAvifImage = class(THeicImage)
  public
    constructor Create; override;
  end;

implementation

function WriterFun(ctx: PHeifContext; const data: Pointer; size: PtrUInt; userdata: Pointer): THeifError;
var Str: TStream;
begin
  Str := TStream(userData^);
  try
    Str.Write(Data^, Size);
  except
    Result.code := 1;
  end;
  Result.code := 0;
end;

{ THeicImage }

procedure THeicImage.DecodeFromStream(Str: TStream);
var Ctx: PHeifContext;
    ImageHandle: PHeifImageHandle;
    Image: PHeifImage;
    Data:  PByte;
    DataStride: Integer;
    AWidth, AHeight: Integer;
    x,y: Integer;
    P: PByteArray;
    Error:  THeifError;
    mem: array of byte;
    Padding: Integer;
begin
    Ctx := heif_context_alloc();
    try
      SetLength(Mem, Str.Size);
      Str.Read(Mem[0], Str.Size);

      heif_context_read_from_memory_without_copy(Ctx, @Mem[0], Str.size, nil);
      heif_context_get_primary_image_handle(Ctx, ImageHandle);

      try
        Error := heif_decode_image(imageHandle, Image, Integer(heif_colorspace_RGB), Integer(heif_chroma_interleaved_RGBA), nil);

        if Error.code <> 0 then raise Exception.Create('Decoding error');

        AWidth := heif_image_handle_get_width(imagehandle);
        AHeight := heif_image_handle_get_height(imagehandle);

        Data := heif_image_get_plane(Image, Integer(heif_channel_interleaved), DataStride);

        if DataStride < 1 then raise Exception.Create('Failed to get image plane');

        Padding := DataStride - (AWidth*4);
        FBmp.SetSize(AWidth, AHeight);

        for y:=0 to FBmp.Height-1 do begin
          P := FBmp.Scanline[y];

          for x:=0 to FBmp.Width-1 do begin
            P[4*x+2] := Data^; Inc(Data);
            P[4*x+1] := Data^; Inc(Data);
            P[4*x  ] := Data^; Inc(Data);
            P[4*x+3] := Data^; Inc(Data); //alpha
          end;
          Inc(Data, Padding);
        end;

      finally
        heif_image_handle_release(ImageHandle);
      end;
    finally
      heif_context_free(Ctx);
    end;
end;

procedure THeicImage.EncodeToStream(Str: TStream);
var Ctx: PHeifContext;
    Encoder: PHeifEncoder;
    Image: PHeifImage;
    Writer: THeifWriter;
    DataStride: Integer;
    Data: PByte;
    P: PByteArray;
    Padding: Integer;
    x,y: Integer;
    Method: Integer;
begin
  if IsHeic then Method := Integer(compression_HEVC)
  else           Method := Integer(compression_AV1);

  Ctx := heif_context_alloc();

  heif_image_create(Width, Height, Integer(heif_colorspace_RGB), Integer(heif_chroma_interleaved_RGB), Image);
  heif_image_add_plane(Image, Integer(heif_channel_interleaved), Width, Height, 24);

  Data := heif_image_get_plane(Image, Integer(heif_channel_interleaved), DataStride);
  Padding := DataStride - (FBmp.Width*3);

  for y:=0 to FBmp.Height-1 do begin
    P := FBmp.Scanline[y];

    for x:=0 to FBmp.Width-1 do begin
      Data^ := P[4*x+2]; Inc(Data);
      Data^ := P[4*x+1]; Inc(Data);
      Data^ := P[4*x  ]; Inc(Data);
    end;

    Inc(Data, Padding);
  end;

  try
    heif_context_get_encoder_for_format(Ctx, Method, Encoder);
    try
      if FCompression < 0 then heif_encoder_set_lossless(Encoder, true)
      else                     heif_encoder_set_lossy_quality(Encoder, FCompression);
      heif_context_encode_image(Ctx, Image, Encoder, nil, nil);
    finally
      heif_encoder_release(Encoder);
    end;

    Writer.writer_api_version := 1;
    Writer.write := @WriterFun;

    heif_context_write(Ctx, Writer, @Str);
  finally
    heif_context_free(Ctx);
  end;
end;

procedure THeicImage.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  ACanvas.StretchDraw(Rect, FBmp);
end;

function THeicImage.GetHeight: Integer;
begin
  Result := FBmp.Height;
end;

function THeicImage.GetTransparent: Boolean;
begin
  Result := False;
end;

function THeicImage.GetWidth: Integer;
begin
  Result := FBmp.Width;
end;

procedure THeicImage.SetHeight(Value: Integer);
begin
  FBmp.Height := Value;
end;

procedure THeicImage.SetTransparent(Value: Boolean);
begin
  //
end;

procedure THeicImage.SetWidth(Value: Integer);
begin
  FBmp.Width := Value;
end;

procedure THeicImage.SetLossyCompression(Value: Cardinal);
begin
  if Value > 100 then Value := 100;
  FCompression := Value;
end;

procedure THeicImage.SetLosslessCompression;
begin
  FCompression := -1;
end;

procedure THeicImage.Assign(Source: TPersistent);
var Src: TGraphic;
begin
  if source is tgraphic then begin
    Src := Source as TGraphic;
    FBmp.SetSize(Src.Width, Src.Height);
    FBmp.Canvas.Draw(0,0, Src);
  end;
end;

procedure THeicImage.LoadFromStream(Stream: TStream);
begin
  DecodeFromStream(Stream);
end;

procedure THeicImage.SaveToStream(Stream: TStream);
begin
  EncodeToStream(Stream);
end;

constructor THeicImage.Create;
begin
  inherited Create;

  FBmp := TBitmap.Create;
  FBmp.PixelFormat := pf32bit;
  FBmp.SetSize(1,1);
  IsHeic := True;
  FCompression := 90;
end;

destructor THeicImage.Destroy;
begin
  FBmp.Free;
  inherited Destroy;
end;

function THeicImage.ToBitmap: TBitmap;
begin
  Result := FBmp;
end;

{ TAvifImage }

constructor TAvifImage.Create;
begin
  inherited Create;
  IsHeic := False;
end;

initialization
  TPicture.RegisterFileFormat('heic','HEIC Image', THeicImage);
  TPicture.RegisterFileFormat('avif','AVIF Image', TAvifImage);

finalization
  TPicture.UnregisterGraphicClass(THeicImage);
  TPicture.UnregisterGraphicClass(TAvifImage);

end.
