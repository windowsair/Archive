
`ifndef _INCL_DEFINITIONS
`define _INCL_DEFINITIONS

/*
  Cell Formats
*/
/* UNI Cell Format */
typedef struct packed {
  bit        [3:0]  GFC;   // 在lab3中随机生成
  bit        [7:0]  VPI;   // 在lab3中随机生成
  bit        [15:0] VCI;   // 在lab3中随机生成
  bit               CLP;   // 在lab3中随机生成
  bit        [2:0]  PT;    // 在lab3中随机生成
  bit        [7:0]  HEC;   // HEC只与上面这几个字段有关
  bit [0:47] [7:0]  Payload;
} uniType;

/* NNI Cell Format */
typedef struct packed {
  bit        [11:0] VPI;
  bit        [15:0] VCI;
  bit               CLP;
  bit        [2:0]  PT;
  bit        [7:0]  HEC;
  bit [0:47] [7:0]  Payload;
} nniType;

/* Test View Cell Format (Payload Section) */
typedef struct packed {
  bit [0:4]  [7:0] Header;
  bit [0:3]  [7:0] PortID;
  bit [0:3]  [7:0] CellID;
  bit [0:39] [7:0] Padding;
} tstType;

/*
  Union of UNI / NNI / Test View / ByteStream
*/
typedef union packed {
  uniType uni;
  nniType nni;
  tstType tst;
  bit [0:52] [7:0] Mem;
} ATMCellType; // 完整的信元结构(union类型)

/*
  Cell Rewriting and Forwarding Configuration
*/
typedef struct packed {
  bit [`TxPorts-1:0] FWD; // 转发表的物理地址
  bit [11:0] VPI;         // NNI报文的VPI值
} CellCfgType;

`endif // _INCL_DEFINITIONS
