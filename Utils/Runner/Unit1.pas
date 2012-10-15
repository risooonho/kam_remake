unit Unit1;
{$I KaM_Remake.inc}
interface
uses
  Forms, Controls, StdCtrls, Spin, ExtCtrls, Classes, SysUtils, Graphics, Types, Math, Windows,
  Unit_Runner;


type
  TForm2 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Memo1: TMemo;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    ListBox1: TListBox;
    Memo2: TMemo;
    RadioGroup1: TRadioGroup;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    fResults: TKMRunResults;
    fRunTime: string;
    procedure RunnerProgress(const aValue: string);
  end;


var
  Form2: TForm2;


implementation
{$R *.dfm}


procedure TForm2.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(RunnerList) do
    ListBox1.Items.Append(RunnerList[I].ClassName);
end;


procedure TForm2.Button1Click(Sender: TObject);
var
  T: Cardinal;
  ID, Count: Integer;
  RunnerClass: TKMRunnerClass;
  Runner: TKMRunnerCommon;
begin
  ID := ListBox1.ItemIndex;
  if ID = -1 then Exit;
  Count := SpinEdit1.Value;
  if Count <= 0 then Exit;

  Memo1.Clear;
  Button1.Enabled := False;
  try
    RunnerClass := RunnerList[ID];
    Runner := RunnerClass.Create;
    Runner.OnProgress := RunnerProgress;
    try
      T := GetTickCount;
      fResults := Runner.Run(Count);
      fRunTime := 'Done in ' + IntToStr(GetTickCount - T) + ' ms';
    finally
      Runner.Free;
    end;

    RadioGroup1Click(nil);
  finally
    Button1.Enabled := True;
  end;
end;


procedure TForm2.RadioGroup1Click(Sender: TObject);
const
  LineCol: array [0..MAX_VALUES - 1] of TColor =
    (clRed, clBlue, clGreen, clPurple, clYellow, clGray, clBlack, clOlive);
var
  J: Integer;
  I: Integer;
  DotX, DotY: Word;
  StatMax: Single;
  Stats: array of Integer;
  S: string;
begin
  Memo1.Clear;
  Image1.Canvas.FillRect(Image1.Canvas.ClipRect);

  for J := 0 to fResults.ValCount - 1 do
  begin
    Image1.Canvas.Pen.Color := LineCol[J];
    case RadioGroup1.ItemIndex of
      0:  for I := 0 to fResults.RunCount - 1 do
          begin
            DotX := Round(I / fResults.RunCount * Image1.Width);
            DotY := Image1.Height - Round(fResults.Value[I,J] / fResults.ValueMax * Image1.Height);
            Image1.Canvas.Ellipse(DotX-2, DotY-2, DotX+2, DotY+2);
            if I = 0 then
              Image1.Canvas.PenPos := Point(DotX, DotY)
            else
              Image1.Canvas.LineTo(DotX, DotY);
          end;
      1:  begin
            SetLength(Stats, Round(fResults.ValueMax) - Round(fResults.ValueMin) + 1);
            for I := 0 to fResults.RunCount - 1 do
              Inc(Stats[Round(fResults.Value[I,J]) - Round(fResults.ValueMin)]);

            StatMax := Stats[Low(Stats)];
            for I := Low(Stats)+1 to High(Stats) do
              StatMax := Max(StatMax, Stats[I]);

            for I := Low(Stats) to High(Stats) do
            begin
              DotX := Round((I - Low(Stats)) / Length(Stats) * Image1.Width);
              DotY := Image1.Height - Round(Stats[I] / StatMax * Image1.Height);
              Image1.Canvas.Ellipse(DotX-2, DotY-2, DotX+2, DotY+2);
              if I = 0 then
                Image1.Canvas.PenPos := Point(DotX, DotY)
              else
                Image1.Canvas.LineTo(DotX, DotY);
            end;
          end;
    end;
  end;

  for I := 0 to fResults.RunCount - 1 do
  begin
    S := IntToStr(I) + '.';
    for J := 0 to fResults.ValCount - 1 do
      S := S + Format(' %.2f', [fResults.Value[I,J]]);
    Memo1.Lines.Append(S);
  end;

  Memo1.Lines.Append(fRunTime);
end;


procedure TForm2.RunnerProgress(const aValue: string);
begin
  Label2.Caption := aValue;
  Label2.Refresh;
  Application.ProcessMessages;
end;

end.