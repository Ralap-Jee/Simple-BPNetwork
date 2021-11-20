library verilog;
use verilog.vl_types.all;
entity cycloneive_asmiblock is
    generic(
        lpm_type        : string  := "cycloneive_asmiblock";
        enable_sim      : string  := "false"
    );
    port(
        dclkin          : in     vl_logic;
        scein           : in     vl_logic;
        oe              : in     vl_logic;
        sdoin           : in     vl_logic;
        data0out        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of lpm_type : constant is 1;
    attribute mti_svvh_generic_type of enable_sim : constant is 1;
end cycloneive_asmiblock;
