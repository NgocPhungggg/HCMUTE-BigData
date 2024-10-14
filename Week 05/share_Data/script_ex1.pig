A = LOAD 'Apache_Pig/Pig_Input/tstat-sample.txt'
    USING PigStorage(' ')
    AS (ip_c:chararray, port_c:int, packets_c:int, rst_c:int, ack_c:int, purack_c:int,
        unique_bytes_s:long, data_pkts_s:int, data_bytes_s:long, rexmit_pkts_s:int, 
        rexmit_bytes_s:long, out_seq_pkts_s:int, syn_s:int, fin_s:int, ws_s:int, ts_s:int, 
        window_scale_s:int, sack_req_s:int, sack_sent_s:int, mss_s:int, max_seg_size_s:int, 
        min_seg_size_s:int, win_max_s:int, win_min_s:int, c_first_ack:double,
        s_first_ack:double, first_time_abs:double, c_internal:int, s_internal:int,
        connection_type:int, p2p_type:int, p2p_subtype:int, ed2k_data:int, ed2k_signaling:int, 
        ed2k_c2s:int,ed2k_c2c:int, ed2k_chat:int, http_type:int, ssl_client_hello:chararray, 
        ssl_server_hello:chararray, dropbox_id:bytearray, fqdn:chararray);
B = GROUP A BY ip_c;
C = FOREACH B GENERATE GROUP, COUNT(A);
DUMP C;