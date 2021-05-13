`include "definitions.svh"

typedef class NNI_cell;
typedef class UNI_cell;

virtual class Common_cell;
  rand bit [15:0] VCI_;
  rand bit CLP_;
  rand bit [2:0] PT_;
  bit [7:0] HEC_;
  rand bit [0:47][7:0] Payload_;

  static bit [7:0] syndrome_[0:255];
  static bit isSyndromeGenerated_ = 0;

  extern function new();
  extern function void generate_syndrome();
  extern function bit [7:0] hec(bit [31:0] hdr);

  pure virtual function void display(input string prefix = "");

endclass : Common_cell


function Common_cell::new();
  if (!isSyndromeGenerated_) generate_syndrome();
endfunction

//---------------------------------------------------------------------------
// Generate the syndome array, used to compute HEC
function void Common_cell::generate_syndrome();
  bit [7:0] sndrm;
  for (int i = 0; i < 256; i = i + 1) begin
    sndrm = i;
    repeat (8) begin
      if (sndrm[7] === 1'b1) sndrm = (sndrm << 1) ^ 8'h07;
      else sndrm = sndrm << 1;
    end
    syndrome_[i] = sndrm;
  end
  isSyndromeGenerated_ = 1;
endfunction : generate_syndrome


// compute 32 bit crc
function bit [7:0] Common_cell::hec(bit [31:0] hdr);
  hec = 8'h00;
  repeat (4) begin
    hec = syndrome_[hec ^ hdr[31:24]];
    hdr = hdr << 8;
  end
  hec = hec ^ 8'h55;
endfunction : hec


/////////////////////////////////////////////////////////////////////////////
// UNI Cell Format
/////////////////////////////////////////////////////////////////////////////
class UNI_cell extends Common_cell;
  // Physical fields
  rand bit [3:0] GFC_;
  rand bit [7:0] VPI_;

  extern function new();
  extern function void post_randomize(); // -> compute HEC

  extern function void pack(output ATMCellType to);
  extern function NNI_cell to_NNI(input bit [11:0] nni_VPI);
  extern function UNI_cell copy();

  extern function bit [7:0] getVPI();
  extern function void setVPI(bit [7:0] newVPI); // TODO: should we use input ?

  extern virtual function void display(input string prefix = "");

endclass : UNI_cell



//-----------------------------------------------------------------------------
function UNI_cell::new();
  super.new();
endfunction : new


//-----------------------------------------------------------------------------
// Compute the HEC value after all other data has been chosen
function void UNI_cell::post_randomize();
  HEC_ = hec({GFC_, VPI_, VCI_, CLP_, PT_});
endfunction : post_randomize


function bit [7:0] UNI_cell::getVPI();
  return this.VPI_;
endfunction : getVPI


function void UNI_cell::setVPI(bit [7:0] newVPI);
  this.VPI_ = newVPI;
endfunction : setVPI


function void UNI_cell::pack(output ATMCellType to);
  to.uni.GFC = this.GFC_;
  to.uni.VPI = this.VPI_;
  to.uni.VCI = this.VCI_;
  to.uni.CLP = this.CLP_;
  to.uni.PT = this.PT_;
  to.uni.HEC = this.HEC_;
  to.uni.Payload = this.Payload_;
  //$write("Packed: "); foreach (to.Mem[i]) $write("%x ", to.Mem[i]); $display;
endfunction : pack


// Generate a NNI cell from an UNI cell - used in scoreboard
function NNI_cell UNI_cell::to_NNI(input bit [11:0] nni_VPI);
  NNI_cell copy = new();

  copy.VPI_ = nni_VPI;  // NNI has wider VPI
  copy.VCI_ = this.VCI_;
  copy.CLP_ = this.CLP_;
  copy.PT_ = this.PT_;
  copy.HEC_ = this.HEC_;
  copy.Payload_ = this.Payload_;

  copy.nni_hec();
  return copy;
endfunction : to_NNI


function UNI_cell UNI_cell::copy();
  UNI_cell uni_copy = new();

  uni_copy.GFC_ = this.GFC_;
  uni_copy.VPI_ = this.VPI_;
  uni_copy.VCI_ = this.VCI_;
  uni_copy.CLP_ = this.CLP_;
  uni_copy.PT_ = this.PT_;
  uni_copy.HEC_ = this.HEC_;
  uni_copy.Payload_ = this.Payload_;

  return uni_copy;
endfunction : copy


function void UNI_cell::display(input string prefix);
  ATMCellType p;

  $display("%sUNI  GFC=%x, VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x", prefix, GFC_,
           VPI_, VCI_, CLP_, PT_, HEC_, Payload_[0]);


  this.pack(p);
  $write("%s", prefix);
  foreach (p.Mem[i]) $write("%x ", p.Mem[i]);
  $display;
  //$write("%sUNI Payload=%x %x %x %x %x %x ...",
  //	  prefix, Payload[0], Payload[1], Payload[2], Payload[3], Payload[4], Payload[5]);
  //foreach(Payload[i]) $write(" %x", Payload[i]);
  $display;
endfunction : display

/////////////////////////////////////////////////////////////////////////////
// NNI Cell Format
/////////////////////////////////////////////////////////////////////////////
class NNI_cell extends Common_cell;
  // Physical fields
  rand bit [11:0] VPI_;
  rand bit [15:0] VCI_;

  bit shouldBeDrop_;

  extern function new();
  extern function void nni_hec();
  extern function bit compare(input NNI_cell cmp);
  extern function void unpack(input ATMCellType from);

  extern function void setDrop();
  extern function bit getDrop();

  extern function bit [11:0] getVPI();
  extern function void setVPI(bit [11:0] newVPI);  // TODO: should we use input ?

  extern virtual function void display(input string prefix = "");


endclass : NNI_cell


function NNI_cell::new();
  super.new();
  this.shouldBeDrop_ = 0;
endfunction : new

function void NNI_cell::setDrop();
  this.shouldBeDrop_ = 1;
endfunction : setDrop

function bit NNI_cell::getDrop();
  return this.shouldBeDrop_;
endfunction


//-----------------------------------------------------------------------------
// Compute the HEC value after all other data has been chosen
function void NNI_cell::nni_hec();
  HEC_ = hec({VPI_, VCI_, CLP_, PT_});
endfunction : nni_hec


// return : isSuccess
function bit NNI_cell::compare(input NNI_cell cmp);
  if (this.VPI_ != cmp.VPI_) return 0;
  if (this.VCI_ != cmp.VCI_) return 0;
  if (this.CLP_ != cmp.CLP_) return 0;
  if (this.PT_ != cmp.PT_) return 0;
  if (this.HEC_ != cmp.HEC_) return 0;
  if (this.Payload_ != cmp.Payload_) return 0;
  return 1;
endfunction : compare


function void NNI_cell::unpack(input ATMCellType from);
  this.VPI_ = from.nni.VPI;
  this.VCI_ = from.nni.VCI;
  this.CLP_ = from.nni.CLP;
  this.PT_ = from.nni.PT;
  this.HEC_ = from.nni.HEC;
  this.Payload_ = from.nni.Payload;
endfunction : unpack

function bit [11:0] NNI_cell::getVPI();
  return this.VPI_;
endfunction : getVPI

function void NNI_cell::setVPI(bit [11:0] newVPI);
  this.VPI_ = newVPI;
endfunction : setVPI


function void NNI_cell::display(input string prefix);
  ATMCellType p;

  $display("%sNNI , VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x", prefix, VPI_, VCI_, CLP_,
           PT_, HEC_, Payload_[0]);

  //this.pack(p);
  $write("%s", prefix);
  foreach (p.Mem[i]) $write("%x ", p.Mem[i]);
  $display;
  //$write("%sUNI Payload=%x %x %x %x %x %x ...",
  $display;

endfunction : display
