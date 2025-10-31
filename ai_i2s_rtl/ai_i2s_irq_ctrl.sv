

module ai_i2s_irq_ctrl (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        irq_en,
    input  logic        intmask_high,
    input  logic        intmask_low,
    input  logic        high_buf_full,     // Buffer condition signal
    input  logic        low_buf_full,      // Buffer condition signal
    input  logic        intclr_high,      
    input  logic        intclr_low,        
    output logic        irq_o,
    output logic        intstat_high,
    output logic        intstat_low
);

    // Previous state registers 
    logic high_buf_full_prev;
    logic low_buf_full_prev;

    // Edge detection signals
    logic high_buf_rising_edge;
    logic low_buf_rising_edge;

    // Store previous states 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            high_buf_full_prev <= 1'b0;
            low_buf_full_prev  <= 1'b0;
        end else begin
            high_buf_full_prev <= high_buf_full;
            low_buf_full_prev  <= low_buf_full;
        end
    end

    // Generate edge detection signals
    always_comb begin
        high_buf_rising_edge = high_buf_full & ~high_buf_full_prev;
        low_buf_rising_edge  = low_buf_full & ~low_buf_full_prev;
    end

    //  Edge-triggered interrupt status with proper clear priority
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intstat_high <= 1'b0;
            intstat_low  <= 1'b0;
        end else begin
            // High buffer interrupt logic
            if (intclr_high) begin
                intstat_high <= 1'b0;                    
            end else if (high_buf_rising_edge) begin
                intstat_high <= 1'b1;                
            end
         

            // Low buffer interrupt logic  
            if (intclr_low) begin
                intstat_low <= 1'b0;                  
            end else if (low_buf_rising_edge) begin
                intstat_low <= 1'b1;                   
            end
         
        end
    end

    // IRQ output logic 
    always_comb begin
        irq_o = irq_en & ((intmask_high & intstat_high) | (intmask_low & intstat_low));
    end

endmodule
