// rtl/traffic_light.sv
// Two-way traffic-light controller used as a formal verification example.
// State sequence: NS green -> NS yellow -> EW green -> EW yellow -> repeat.
// A dwell timer holds each state for a fixed number of cycles.
//
// Formal properties are defined at the bottom under `ifdef FORMAL and proven
// with SymbiYosys (see traffic.sby).
`timescale 1ns/1ps
module traffic_light #(
  parameter int GREEN_TIME  = 6,
  parameter int YELLOW_TIME = 2
)(
  input  logic       clk,
  input  logic       rst_n,
  output logic [1:0] ns_light,   // 0 = RED, 1 = GREEN, 2 = YELLOW
  output logic [1:0] ew_light
);
  localparam logic [1:0] RED = 2'd0, GREEN = 2'd1, YELLOW = 2'd2;

  typedef enum logic [1:0] {
    S_NS_GREEN, S_NS_YELLOW, S_EW_GREEN, S_EW_YELLOW
  } state_t;

  state_t      state;
  logic [3:0]  timer;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_NS_GREEN;
      timer <= '0;
    end else begin
      case (state)
        S_NS_GREEN:
          if (timer >= GREEN_TIME[3:0] - 1)  begin state <= S_NS_YELLOW; timer <= '0; end
          else                                       timer <= timer + 1'b1;
        S_NS_YELLOW:
          if (timer >= YELLOW_TIME[3:0] - 1) begin state <= S_EW_GREEN;  timer <= '0; end
          else                                       timer <= timer + 1'b1;
        S_EW_GREEN:
          if (timer >= GREEN_TIME[3:0] - 1)  begin state <= S_EW_YELLOW; timer <= '0; end
          else                                       timer <= timer + 1'b1;
        S_EW_YELLOW:
          if (timer >= YELLOW_TIME[3:0] - 1) begin state <= S_NS_GREEN;  timer <= '0; end
          else                                       timer <= timer + 1'b1;
        default:
          begin state <= S_NS_GREEN; timer <= '0; end
      endcase
    end
  end

  always_comb begin
    ns_light = RED;
    ew_light = RED;
    case (state)
      S_NS_GREEN:  ns_light = GREEN;
      S_NS_YELLOW: ns_light = YELLOW;
      S_EW_GREEN:  ew_light = GREEN;
      S_EW_YELLOW: ew_light = YELLOW;
      default: ;
    endcase
  end

`ifdef FORMAL
  // --------------------------------------------------------------- properties
  logic ns_go, ew_go;
  assign ns_go = (ns_light != RED);
  assign ew_go = (ew_light != RED);

  always @(posedge clk) begin
    if (rst_n) begin
      // Safety: the two directions are never non-red at the same time.
      a_mutex:  assert (!(ns_go && ew_go));
      // Legal encoding: a light is only RED, GREEN, or YELLOW (never 3).
      a_legal:  assert ((ns_light != 2'd3) && (ew_light != 2'd3));

      // Reachability: every phase is actually reached.
      c_ns_green:  cover (ns_light == GREEN);
      c_ew_green:  cover (ew_light == GREEN);
      c_ns_yellow: cover (ns_light == YELLOW);
      c_ew_yellow: cover (ew_light == YELLOW);
    end
  end
`endif
endmodule
