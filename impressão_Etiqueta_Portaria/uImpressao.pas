unit uImpressao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  ppCtrls, ppParameter, ppDesignLayer, ppBands, ppPrnabl, ppClass, ppCache,
  ppComm, ppRelatv, ppProd, ppReport, Registry, ShellAPI, Data.DB,
  Data.Win.ADODB, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Buttons, ppDB,
  ppDBPipe, Vcl.ComCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Phys.MySQL, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MySQLDef;

type
  TfrmEtiqueta = class(TForm)
    ppVisitante: TppReport;
    ppParameterList3: TppParameterList;
    ppDesignLayers3: TppDesignLayers;
    ppDesignLayer3: TppDesignLayer;
    ppHeaderBand3: TppHeaderBand;
    ppDetailBand3: TppDetailBand;
    ppFooterBand3: TppFooterBand;
    ppImage3: TppImage;
    ppLabel12: TppLabel;
    ppLabel13: TppLabel;
    conecta: TADOConnection;
    dsPaciente: TDataSource;
    dbgrdPaciente: TDBGrid;
    pnl1: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    img1: TImage;
    edtBuscaPaciente: TEdit;
    btnBuscaPaciente: TSpeedButton;
    dsEtiqueta: TDataSource;
    pdbVisitante: TppDBPipeline;
    ppDBText1: TppDBText;
    ppDBText3: TppDBText;
    ppLabel2: TppLabel;
    ppLabel1: TppLabel;
    btnVisitante: TBitBtn;
    btnAcompanhante: TBitBtn;
    tmrPaciente: TTimer;
    btnFirst: TSpeedButton;
    btnNext: TSpeedButton;
    btnPrior: TSpeedButton;
    btnLast: TSpeedButton;
    FDConnection1: TFDConnection;
    qryPaciente: TFDQuery;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    qryEtiqueta: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdPacienteDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnBuscaPacienteClick(Sender: TObject);
    procedure edtBuscaPacienteChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure tmrPacienteTimer(Sender: TObject);
    procedure edtBuscaPacienteKeyPress(Sender: TObject; var Key: Char);
    procedure btnFirstClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEtiqueta: TfrmEtiqueta;

implementation

{$R *.dfm}

procedure TfrmEtiqueta.btnBuscaPacienteClick(Sender: TObject);
begin
  qryPaciente.Close;
  qryPaciente.ParamByName('paciente').Value := '%' + edtBuscaPaciente.Text + '%';
  qryPaciente.Open;
  if (qryPaciente.RecordCount = 0) then
  begin
    Application.MessageBox('Nome de Paciente n�o consta na lista.','Alerta',MB_OK+MB_ICONINFORMATION);
    qryPaciente.Close;
    edtBuscaPaciente.Clear;
    qryPaciente.Open;
  end
  else if (Trim(edtBuscaPaciente.Text)='') then
  begin
    Application.MessageBox('Campo Vazio.Favor entrar com o Nome do Paciente.','Aviso',MB_OK+MB_ICONINFORMATION);
  end;
end;

procedure TfrmEtiqueta.btnFirstClick(Sender: TObject);
begin
  qryPaciente.First;
end;

procedure TfrmEtiqueta.btnLastClick(Sender: TObject);
begin
  qryPaciente.Last;
end;

procedure TfrmEtiqueta.btnNextClick(Sender: TObject);
begin
  qryPaciente.Next;
end;

procedure TfrmEtiqueta.btnPriorClick(Sender: TObject);
begin
  qryPaciente.Prior;
end;

procedure TfrmEtiqueta.BitBtn1Click(Sender: TObject);
begin
  qryEtiqueta.ParamByName('codpaciente').Value := qryPaciente.FieldByName('CODPACIENTE').Value;
  qryEtiqueta.ParamByName('codatendimento').Value := qryPaciente.FieldByName('CODATENDIMENTO').Value;
  ppLabel1.Caption := 'VISITANTE';
  qryEtiqueta.Close;
  qryEtiqueta.Open;
  ppVisitante.PrinterSetup.Copies := 1;
  ppVisitante.Print;
end;

procedure TfrmEtiqueta.BitBtn2Click(Sender: TObject);
begin
  qryEtiqueta.ParamByName('codpaciente').Value := qryPaciente.FieldByName('CODPACIENTE').Value;
  qryEtiqueta.ParamByName('codatendimento').Value := qryPaciente.FieldByName('CODATENDIMENTO').Value;
  ppLabel1.Caption := 'ACOMPANHANTE';
  qryEtiqueta.Close;
  qryEtiqueta.Open;
  ppVisitante.PrinterSetup.Copies := 1;
  ppVisitante.Print;
end;

procedure TfrmEtiqueta.dbgrdPacienteDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  with dbgrdPaciente do
  begin
    If gdSelected in State then
    begin
      Canvas.Brush.Color := RGB(141,182,205);
      Canvas.Font.Color := clWhite;
    end
    else
    if Odd(dsPaciente.DataSet.RecNo) then
    begin
      Canvas.Brush.Color := clGradientInactiveCaption;
    end
    else
    begin
      Canvas.Brush.Color := clWindow;
    end;

    Canvas.FillRect(Rect);
    DefaultDrawColumnCell(Rect,DataCol,Column,State);
  end;
end;

procedure TfrmEtiqueta.edtBuscaPacienteChange(Sender: TObject);
begin
  qryPaciente.Close;
  qryPaciente.ParamByName('paciente').Value := '%' + edtBuscaPaciente.Text + '%';
  qryPaciente.Open;

  ShowScrollBar(dbgrdPaciente.Handle,SB_VERT,True);

  {qryPaciente.Locate('NOMEPACIENTE',edtBuscaPaciente.Text,[loCaseInsensitive,loPartialKey]);
  if (trim(edtBuscaPaciente.Text) = '') then
  begin
    qryPaciente.First;
  end; }

  {if (qryPaciente.RecordCount = 0) then
  begin
    Application.MessageBox('Nome de Paciente n�o consta na lista.','Alerta',MB_OK+MB_ICONINFORMATION);
    qryPaciente.Close;
    edtBuscaPaciente.Clear;
    qryPaciente.Open;
  end;  }
end;

procedure TfrmEtiqueta.edtBuscaPacienteKeyPress(Sender: TObject; var Key: Char);
begin
  If(key in['0'..'9',#13] ) then
  begin
    key:=#0;
    Application.MessageBox('O sistema n�o aceita numeros como entradas, favor informe o nome do Paciente.','Aviso',MB_OK+MB_IconQuestion);
  end;
end;

procedure TfrmEtiqueta.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Application.MessageBox('Deseja encerrar o Programa?','Informa��o',MB_YESNO+MB_ICONQUESTION) <> IDYES then
  begin
     Action := caNone
  end
  else
  begin
    Action := caFree;
    qryPaciente.Close;
    qryEtiqueta.Close;
  end;

end;

procedure TfrmEtiqueta.FormCreate(Sender: TObject);
var
REG:TRegistry;
begin
  FDPhysMySQLDriverLink1.vendorlib := extractfilepath( application.exename ) + 'libmysql.dll';
  qryPaciente.Close;
  qryPaciente.ParamByName('paciente').Value := '%';
  REG := TRegistry.Create;
  REG.RootKey := HKEY_CURRENT_USER;
  REG.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run\',false);
  REG.WriteString('Meu Programa',ParamStr(0));
  REG.CloseKey;
  REG.Free;
  //ShowMessage('Programa adicionado na inicializa��o do windows com sucesso!');
  qryPaciente.Open;

  qryEtiqueta.Close;
  qryEtiqueta.Open;
end;


procedure TfrmEtiqueta.tmrPacienteTimer(Sender: TObject);
begin
  qryPaciente.Close;
  qryPaciente.ParamByName('paciente').Value := '%';
  edtBuscaPaciente.Clear;
  qryPaciente.Open;
end;

end.
