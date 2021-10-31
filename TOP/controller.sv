`include "define.sv"

module controller(
  input         [`data_size-1:0]    instruction,
  input								interrupt,

  output logic  [2:0]               MEM_ctr,  // MEM_ctr = {branch, DM_write, DM_enable}
  output logic  [2:0]               WB_ctr,  // WB_ctr = {jal_sel, RF_write, lw_select}
  output logic                      RF_read,
  output logic                      csr_read,
  output logic                      csr_write,
  output logic                      imm_select,
  output logic                      alu_en,
  output logic                      utype_sel,
  output logic                      asipc_sel,
  output logic [1:0]                csr_imm_sel,
  output logic                      csr_result_sel,
  output logic 						wfi_stall,
  output logic						flag_mret
);

  logic     [6:0]                   opcode;
  logic     [2:0]                   funct3;


  assign opcode = instruction[6:0];
  assign funct3 = instruction[14:12];

  always_comb begin
    case(opcode)
      `Rtype:begin
        MEM_ctr         = 3'b000;
        WB_ctr          = 3'b011;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b0;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `Itype:begin
        if(instruction[31:20] == 12'b0)begin  // NOP
          MEM_ctr         = 3'b000;
          WB_ctr          = 3'b011;
          RF_read      	  = 1'b1;
          csr_read        = 1'b0;
          csr_write       = 1'b0;
          imm_select      = 1'b1;
          alu_en          = 1'b1;
          utype_sel       = 1'b0;
          asipc_sel       = 1'b0;
          csr_imm_sel     = 2'b0;
          csr_result_sel  = 1'b0;
		  wfi_stall	      = 1'b0;
		  flag_mret	      = 1'b0;
        end
        else begin  // Itype
          MEM_ctr         = 3'b000;
          WB_ctr          = 3'b011;
          RF_read         = 1'b1;
          csr_read        = 1'b0;
          csr_write       = 1'b0;
          imm_select      = 1'b1;
          alu_en          = 1'b1;
          utype_sel       = 1'b0;
          asipc_sel       = 1'b0;
          csr_imm_sel     = 2'b0;
          csr_result_sel  = 1'b0;
		  wfi_stall	      = 1'b0;
		  flag_mret	      = 1'b0;
        end
      end
      7'b0000011:begin  // LW, LB, LH, LBU, LHU
        MEM_ctr         = 3'b001;
        WB_ctr          = 3'b010;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
	    wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `Stype:begin
        MEM_ctr         = 3'b011;
        WB_ctr          = 3'b000;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `Btype:begin
        MEM_ctr         = 3'b100;
        WB_ctr          = 3'b001;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b0;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `Utype:begin
        MEM_ctr         = 3'b000;
        WB_ctr          = 3'b011;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b1;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `Jtype:begin
        MEM_ctr         = 3'b100;
        WB_ctr          = 3'b111;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `JALR:begin
        MEM_ctr         = 3'b100;
        WB_ctr          = 3'b111;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `AUIPC:begin
        MEM_ctr         = 3'b000;
        WB_ctr          = 3'b011;
        RF_read         = 1'b1;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b1;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
      `CSR:begin
	    priority if(funct3 == 3'b000)begin  // WFI, MRET
		  case(instruction[24:20])
		  5'b00010:begin  // MRET
			MEM_ctr         = 3'b0;
        	WB_ctr          = 3'b0;
        	RF_read         = 1'b0;
        	csr_read        = 1'b1;
        	csr_write       = 1'b0;				
        	imm_select      = 1'b0;		 
        	alu_en          = 1'b0;		 
        	utype_sel       = 1'b0;		 
        	asipc_sel       = 1'b0;		 
        	csr_imm_sel     = 2'b0;		 
        	csr_result_sel  = 1'b0;
        	wfi_stall		= 1'b0;
		    flag_mret	    = 1'b1;
		  end  
		  5'b00101:begin  // WFI
		     MEM_ctr         = 3'b0;
		     WB_ctr          = 3'b0;
		     RF_read         = 1'b0;
		     csr_read        = 1'b0;
		     csr_write       = 1'b1;				
		     imm_select      = 1'b0;		 
		     alu_en          = 1'b0;		 
		     utype_sel       = 1'b0;		 
		     asipc_sel       = 1'b0;		 
		     csr_imm_sel     = 2'b10;		 
		     csr_result_sel  = 1'b0;
			 wfi_stall		 = (interrupt)? 1'b0 : 1'b1;
		     flag_mret	     = 1'b0;
		  end 
		  endcase
		else if(((funct3 == 3'b001) || (funct3 == 3'b101)) && instruction[11:7] == 5'b0)begin  // exception of CSRRW, CSRRWI
          MEM_ctr         = 3'b0;
          WB_ctr          = 3'b001;
          RF_read         = 1'b1;
          csr_read        = 1'b0;
          csr_write       = 1'b1;
          imm_select      = 1'b0;
          alu_en          = 1'b1;
          utype_sel       = 1'b0;
          asipc_sel       = 1'b0;
          csr_imm_sel     = 2'b0;
          csr_result_sel  = 1'b0;
		  wfi_stall	      = 1'b0;
		  flag_mret	      = 1'b0;
        end
        else if(instruction[19:15] == 5'b0)begin  // exception of CSRRS, CSRRC, CSRRSI, CSRRCI
          MEM_ctr         = 3'b0;
          WB_ctr          = 3'b011;
          RF_read         = 1'b0;
          csr_read        = 1'b1;
          csr_write       = 1'b0;
          imm_select      = 1'b0;
          alu_en          = 1'b1;
          utype_sel       = 1'b0;
          asipc_sel       = 1'b0;
          csr_imm_sel     = 2'b0;
          csr_result_sel  = 1'b1;
		  wfi_stall	      = 1'b0;
		  flag_mret	      = 1'b0;
        end		
        else begin
          case(funct3)
          3'b101, 3'b110, 3'b111:begin  // use zimm instead of rs1.
            MEM_ctr         = 3'b000;
            WB_ctr          = 3'b011;
            RF_read         = 1'b1;
            csr_read        = 1'b1;
            csr_write       = 1'b1;
            imm_select      = 1'b0;
            alu_en          = 1'b1;
            utype_sel       = 1'b0;
            asipc_sel       = 1'b0;
            csr_imm_sel     = 2'b01;
            csr_result_sel  = 1'b1;
		    wfi_stall	    = 1'b0;
		    flag_mret	    = 1'b0;
          end
          default:begin
            MEM_ctr         = 3'b000;
            WB_ctr          = 3'b011;
            RF_read         = 1'b1;
            csr_read        = 1'b1;
            csr_write       = 1'b1;
            imm_select      = 1'b0;
            alu_en          = 1'b1;
            utype_sel       = 1'b0;
            asipc_sel       = 1'b0;
            csr_imm_sel     = 2'b0;
            csr_result_sel  = 1'b1;
		    wfi_stall	    = 1'b0;
		    flag_mret	    = 1'b0;
          end
          endcase
        end
      end
      default:begin
        MEM_ctr         = 3'b0;
        WB_ctr          = 3'b0;
        RF_read         = 1'b0;
        csr_read        = 1'b0;
        csr_write       = 1'b0;
        imm_select      = 1'b0;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
        csr_imm_sel     = 2'b0;
        csr_result_sel  = 1'b0;
		wfi_stall	    = 1'b0;
		flag_mret	    = 1'b0;
      end
    endcase
  end

endmodule
