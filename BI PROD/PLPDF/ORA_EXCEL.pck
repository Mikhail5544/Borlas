CREATE OR REPLACE PACKAGE PLPDF.ORA_EXCEL AUTHID CURRENT_USER IS

   /*
    *  ORAEXCEL version 2.0.33
    *  Documentation and examples available on http://www.oraexcel.com/documentation
    *
    */

    /***************************************************************************
    *
    * ORA_EXCEL COPYRIGHT AND LEGAL NOTES
    *
    * This software is protected by International copyright Law. Unauthorized use, 
    * duplication, reverse engineering, any form of redistribution, or use in part 
    * or in whole other than by prior, express, printed and signed license for use
    * is subject to civil and criminal prosecution. If you have received this file 
    * in error, please notify copyright holder and destroy this and any other copies 
    * as instructed. 
    *
    * END-USER LICENSE AGREEMENT FOR ORA_EXCEL IMPORTANT PLEASE READ THE TERMS AND
    * CONDITIONS OF THIS LICENSE AGREEMENT CAREFULLY BEFORE CONTINUING WITH THIS 
    * PROGRAM INSTALL: ORA_EXCEL End-User License Agreement ("EULA") is a legal 
    * agreement between you (either an individual or a single entity) and ORA_EXCEL. 
    * For the ORA_EXCEL software product(s) identified above which may include 
    * associated software components, media, printed materials, and "online" or 
    * electronic documentation ("ORA_EXCEL"). By installing, copying, or otherwise 
    * using the SOFTWARE PRODUCT, you agree to be bound by the terms of this EULA. 
    * This license agreement represents the entire agreement concerning the program 
    * between you and ORA_EXCEL, (referred to as "licenser"), and it supersedes any 
    * prior proposal, representation, or understanding between the parties. If you 
    * do not agree to the terms of this EULA, do not install or use the SOFTWARE PRODUCT.
    * 
    * The SOFTWARE PRODUCT is protected by copyright laws and international copyright 
    * treaties, as well as other intellectual property laws and treaties. 
    * The SOFTWARE PRODUCT is licensed, not sold.
    * 
    * 1. GRANT OF LICENSE. 
    * The SOFTWARE PRODUCT is licensed as follows: 
    * (a) Installation and Use.
    * ORA_EXCEL grants you the right to install and use copies of the SOFTWARE PRODUCT 
    * on your computer running a validly licensed copy of the operating system for which 
    * the SOFTWARE PRODUCT was designed.
    * (b) Backup Copies.
    * You may also make copies of the SOFTWARE PRODUCT as may be necessary for backup 
    * and archival purposes.
    * 
    * 2. DESCRIPTION OF OTHER RIGHTS AND LIMITATIONS.
    * (a) Maintenance of Copyright Notices.
    * You must not remove or alter any copyright notices on any and all copies of the 
    * SOFTWARE PRODUCT.
    * (b) Distribution.
    * You may not distribute registered copies of the SOFTWARE PRODUCT to third parties. 
    * Evaluation versions available for download from ORA_EXCEL's websites may be freely 
    * distributed.
    * (c) Prohibition on Reverse Engineering, Decompilation, and Disassembly.
    * You may not reverse engineer, decompile, or disassemble the SOFTWARE PRODUCT, 
    * except and only to the extent that such activity is expressly permitted by 
    * applicable law notwithstanding this limitation. 
    * (d) Rental.
    * You may not rent, lease, or lend the SOFTWARE PRODUCT.
    * (e) Support Services.
    * ORA_EXCEL may provide you with support services related to the SOFTWARE PRODUCT 
    * ("Support Services"). Any supplemental software code provided to you as part of 
    * the Support Services shall be considered part of the SOFTWARE PRODUCT and subject 
    * to the terms and conditions of this EULA. 
    * (f) Compliance with Applicable Laws.
    * You must comply with all applicable laws regarding use of the SOFTWARE PRODUCT.
    * 3. TERMINATION 
    * Without prejudice to any other rights, ORA_EXCEL may terminate this EULA if you 
    * fail to comply with the terms and conditions of this EULA. In such event, you must 
    * destroy all copies of the SOFTWARE PRODUCT in your possession.
    * 4. COPYRIGHT
    * All title, including but not limited to copyrights, in and to the SOFTWARE PRODUCT 
    * and any copies thereof are owned by ORA_EXCEL or its suppliers. All title and 
    * intellectual property rights in and to the content which may be accessed through 
    * use of the SOFTWARE PRODUCT is the property of the respective content owner and 
    * may be protected by applicable copyright or other intellectual property laws and 
    * treaties. This EULA grants you no rights to use such content. All rights not 
    * expressly granted are reserved by ORA_EXCEL. 
    * 5. NO WARRANTIES
    * ORA_EXCEL expressly disclaims any warranty for the SOFTWARE PRODUCT. 
    * The SOFTWARE PRODUCT is provided 'As Is' without any express or implied warranty 
    * of any kind, including but not limited to any warranties of merchantability, 
    * noninfringement, or fitness of a particular purpose. ORA_EXCEL does not warrant 
    * or assume responsibility for the accuracy or completeness of any information, 
    * text, graphics, links or other items contained within the SOFTWARE PRODUCT. 
    * ORA_EXCEL makes no warranties respecting any harm that may be caused by the 
    * transmission of a computer virus, worm, time bomb, logic bomb, or other such 
    * computer program. ORA_EXCEL further expressly disclaims any warranty or 
    * representation to Authorized Users or to any third party.
    * 6. LIMITATION OF LIABILITY
    * In no event shall ORA_EXCEL be liable for any damages (including, without 
    * limitation, lost profits, business interruption, or lost information) rising
    * out of 'Authorized Users' use of or inability to use the SOFTWARE PRODUCT, 
    * even if ORA_EXCEL has been advised of the possibility of such damages. 
    * In no event will ORA_EXCEL be liable for loss of data or for indirect, 
    * special, incidental, consequential (including lost profit), or other 
    * damages based in contract, tort or otherwise. ORA_EXCEL shall have no 
    * liability with respect to the content of the SOFTWARE PRODUCT or any part 
    * thereof, including but not limited to errors or omissions contained therein, 
    * libel, infringements of rights of publicity, privacy, trademark rights, 
    * business interruption, personal injury, loss of privacy, moral rights or 
    * the disclosure of confidential information. 
    * 
    ****************************************************************************/


    -- Declaration of columns widths
    TYPE column_properites_type IS RECORD (column_name VARCHAR2(2), 
                                           width NUMBER, 
                                           hidden INTEGER DEFAULT 0);  
    TYPE column_properites_table IS TABLE OF column_properites_type; 
    column_properites_empty column_properites_table := column_properites_table(); 
    
    -- Declaration of merged cells type
    TYPE merged_cells_type IS RECORD(merged_cells VARCHAR2(100)); 
    TYPE merged_cells_table IS TABLE OF merged_cells_type; 
    merged_cells_empty merged_cells_table := merged_cells_table(); 

    -- Declaration of hyperlinks table
    TYPE hyperlinks_type IS RECORD (hyperlink VARCHAR2(1000), 
                                    cell VARCHAR2(10)); 
    TYPE hyperlinks_table IS table OF hyperlinks_type; 
    hyperlinks_empty hyperlinks_table := hyperlinks_table(); 
    
    TYPE internal_hyperlinks_type IS RECORD (hyperlink VARCHAR2(1000), 
                                             cell VARCHAR2(10)); 
    TYPE internal_hyperlinks_table IS table OF internal_hyperlinks_type; 
    internal_hyperlinks_empty internal_hyperlinks_table := internal_hyperlinks_table(); 
    
    
    -- Declaration of comments table
    TYPE comments_type IS RECORD (comment_text VARCHAR2(1000), 
                                  author VARCHAR2(30), 
                                  box_width NUMBER, 
                                  box_height NUMBER, 
                                  row_id INTEGER, 
                                  column_id INTEGER, 
                                  cell VARCHAR2(10)); 
    TYPE comments_table IS TABLE OF comments_type; 
    comments_empty comments_table := comments_table(); 
    
    TYPE sheet_buffer_table IS TABLE OF CLOB; 
    sheet_buffer_empty sheet_buffer_table := sheet_buffer_table(); 
    
     -- Declaration of current cell informations type
    TYPE current_cell_type IS RECORD (cell_name VARCHAR2(20), 
                                      cell_type VARCHAR2(1), 
                                      cell_value VARCHAR2(100), 
                                      format_num_fmt_id PLS_INTEGER := 0, 
                                      format_font_id PLS_INTEGER := 0,  
                                      format_fill_id PLS_INTEGER := 0,  
                                      format_border_id PLS_INTEGER := 0,  
                                      format_xf_id PLS_INTEGER := 0, 
                                      format_id PLS_INTEGER, 
                                      formula VARCHAR2(4000),
                                      bold BOOLEAN := FALSE, 
                                      italic BOOLEAN := FALSE, 
                                      underline BOOLEAN := FALSE, 
                                      color VARCHAR2(8), 
                                      bg_color VARCHAR2(8), 
                                      horizontal_align VARCHAR2(1), 
                                      vertical_align VARCHAR2(1), 
                                      null_value BOOLEAN DEFAULT FALSE, 
                                      border_top BOOLEAN DEFAULT FALSE, 
                                      border_top_style VARCHAR2(6), 
                                      border_top_color VARCHAR2(8), 
                                      border_bottom BOOLEAN DEFAULT FALSE, 
                                      border_bottom_style VARCHAR2(6), 
                                      border_bottom_color VARCHAR2(8), 
                                      border_left BOOLEAN DEFAULT FALSE, 
                                      border_left_style VARCHAR2(6), 
                                      border_left_color VARCHAR2(8), 
                                      border_right BOOLEAN DEFAULT FALSE, 
                                      border_right_style VARCHAR2(6), 
                                      border_right_color VARCHAR2(8), 
                                      border_style VARCHAR2(10), 
                                      border_color VARCHAR2(8), 
                                      wrap_text BOOLEAN DEFAULT FALSE, 
                                      merge_cells BOOLEAN, 
                                      merged_cells_cell_from VARCHAR2(2),  
                                      merges_cells_cell_to VARCHAR2(2),  
                                      merge_rows PLS_INTEGER,  
                                      merge_rows_first BOOLEAN, 
                                      cell_format PLS_INTEGER := 0, 
                                      rotate_text_degree INTEGER := 0, 
                                      indent_left INTEGER := 0, 
                                      indent_right INTEGER := 0,  
                                      cells_to_add VARCHAR2(4000)); 
    current_cell_record current_cell_type;   
    TYPE current_cell_table_type IS TABLE OF current_cell_type INDEX BY PLS_INTEGER; 
    --current_cell current_cell_table_type;
    current_cell_empty current_cell_table_type; 
    
    -- Declaration of sheets type
    TYPE sheets_type IS RECORD (sheet_name VARCHAR2(32), 
                                sheet_data CLOB, 
                                sheet_data_buffer sheet_buffer_table, 
                                last_row_num PLS_INTEGER, 
                                top_right_column PLS_INTEGER,
                                column_properites column_properites_table, 
                                merged_cells merged_cells_table, 
                                merge_rows BOOLEAN DEFAULT FALSE,
                                margins_left NUMBER, 
                                margins_right NUMBER, 
                                margins_top NUMBER,  
                                margins_bottom NUMBER,  
                                margins_header NUMBER,  
                                margins_footer NUMBER,  
                                orientation VARCHAR2(10), 
                                paper_size INTEGER, 
                                header_text VARCHAR2(1000), 
                                footer_text VARCHAR2(1000),   
                                hyperlinks hyperlinks_table, 
                                internal_hyperlinks internal_hyperlinks_table, 
                                comments comments_table, 
                                filter_from VARCHAR2(20),  
                                filter_to VARCHAR2(20), 
                                current_cell current_cell_table_type, 
                                row_height NUMBER, 
                                hide_row BOOLEAN, 
                                freeze_panes_horizontal VARCHAR2(20), 
                                freeze_panes_vertical VARCHAR2(20));   
    TYPE sheets_table IS TABLE OF sheets_type; 
    sheets_empty sheets_table := sheets_table(); 
    
    
    -- Declaration of format masks type
    TYPE format_masks_type IS RECORD(format_mask VARCHAR(60)); 
    TYPE format_masks_table IS TABLE OF format_masks_type; 
    format_masks_empty format_masks_table := format_masks_table(); 
    
    -- Declaration of format masks table
    TYPE formats_type IS RECORD (num_fmt_id PLS_INTEGER, 
                                font_id PLS_INTEGER, 
                                fill_id PLS_INTEGER,  
                                border_id PLS_INTEGER,  
                                xf_id PLS_INTEGER, 
                                horizontal_align VARCHAR2(1), 
                                vertical_align VARCHAR2(1), 
                                wrap_text BOOLEAN, 
                                rotate_text_degree INTEGER, 
                                indent_left INTEGER, 
                                indent_right INTEGER); 
    TYPE formats_table IS table OF formats_type; 
    formats_empty formats_table := formats_table(); 
    
    
    
    -- Declaration of fonts type
    TYPE fonts_type IS RECORD (font_size PLS_INTEGER, 
                               font_name VARCHAR2(100), 
                               italic BOOLEAN := FALSE, 
                               underline BOOLEAN := FALSE, 
                               bold BOOLEAN := FALSE, 
                               color VARCHAR2(8)); 
    TYPE fonts_table IS table OF fonts_type; 
    fonts_empty fonts_table := fonts_table(); 
    
    -- Declaration of fills type
    TYPE fills_type IS RECORD (pattern_type VARCHAR2(10), 
                               color VARCHAR2(8));
    TYPE fills_table IS TABLE OF fills_type; 
    fills_empty fills_table := fills_table();
                               
    
    -- Declaration of default font type
    TYPE default_font_type IS RECORD (font_size PLS_INTEGER,
                                      font_name VARCHAR2(100));

    -- Declaration of borders type
    TYPE borders_type IS RECORD (border_top BOOLEAN DEFAULT FALSE,
                                 border_top_style VARCHAR2(6),
                                 border_top_color VARCHAR2(8),
                                 border_bottom BOOLEAN DEFAULT FALSE,
                                 border_bottom_style VARCHAR2(6),
                                 border_bottom_color VARCHAR2(8),
                                 border_left BOOLEAN DEFAULT FALSE,
                                 border_left_style VARCHAR2(6),
                                 border_left_color VARCHAR2(8),
                                 border_right BOOLEAN DEFAULT FALSE,
                                 border_right_style VARCHAR2(6),
                                 border_right_color VARCHAR2(8),
                                 border_style VARCHAR2(10),
                                 border_color VARCHAR2(8)); 
    TYPE borders_table IS TABLE OF borders_type;
    borders_empty borders_table := borders_table();
    
    
    TYPE shared_buffer_table IS TABLE OF CLOB;
    shared_buffer_empty shared_buffer_table := shared_buffer_table();
        
    TYPE styles_type IS RECORD (style_name VARCHAR2(20), 
                                font_name VARCHAR2(100), 
                                font_size PLS_INTEGER, 
                                formula VARCHAR2(4000),
                                bold BOOLEAN := FALSE, 
                                italic BOOLEAN := FALSE, 
                                underline BOOLEAN := FALSE, 
                                color VARCHAR2(8), 
                                bg_color VARCHAR2(8), 
                                horizontal_align VARCHAR2(20), 
                                vertical_align VARCHAR2(20), 
                                border_top BOOLEAN DEFAULT FALSE, 
                                border_top_style VARCHAR2(6), 
                                border_top_color VARCHAR2(8), 
                                border_bottom BOOLEAN DEFAULT FALSE, 
                                border_bottom_style VARCHAR2(6), 
                                border_bottom_color VARCHAR2(8), 
                                border_left BOOLEAN DEFAULT FALSE, 
                                border_left_style VARCHAR2(6), 
                                border_left_color VARCHAR2(8), 
                                border_right BOOLEAN DEFAULT FALSE, 
                                border_right_style VARCHAR2(6), 
                                border_right_color VARCHAR2(8), 
                                border BOOLEAN, 
                                border_style VARCHAR2(10), 
                                border_color VARCHAR2(8), 
                                wrap_text BOOLEAN DEFAULT FALSE, 
                                format VARCHAR2(60) := NULL, 
                                rotate_text_degree INTEGER := 0, 
                                indent_left INTEGER := 0, 
                                indent_right INTEGER := 0); 
                                
                                   
    TYPE styles_table IS TABLE OF styles_type INDEX BY VARCHAR2(50); 
                        
                                
    
    -- Declaration of documents type
    TYPE documents_type IS RECORD (sheets sheets_table, 
                                   shared_strings CLOB,
                                   shared_strings_buffer shared_buffer_table,
                                   last_shared_string_num PLS_INTEGER,
                                   format_masks format_masks_table, 
                                   formats formats_table,
                                   fonts fonts_table, 
                                   default_font default_font_type,
                                   fills fills_table,
                                   borders borders_table,
                                   have_hyperlinks BOOLEAN,
                                   have_internal_hyperlinks BOOLEAN,
                                   author VARCHAR2(1000), 
                                   styles styles_table); 
    TYPE documents_table IS TABLE OF documents_type;
    documents documents_table;
    documents_empty documents_table := documents_table();
   
    --  Declaration of indexes
    doc_id PLS_INTEGER := 0;
    current_doc_id PLS_INTEGER;
    current_sheet_id PLS_INTEGER; 
    current_row_id PLS_INTEGER;
    initialize_clob CLOB;
    current_cell_number PLS_INTEGER;
    cell_formatted BOOLEAN := FALSE;
    
    -- Declaration of cache objects
    cache_column_alpha_in PLS_INTEGER;
    cache_column_alpha_out VARCHAR2(20);
    cache_column_number_in VARCHAR2(20);
    cache_column_number_out PLS_INTEGER;

    TYPE line_string_type IS TABLE OF VARCHAR2(32767) INDEX BY PLS_INTEGER;
    line_string line_string_type;
    
    TYPE shared_strings_buffer_type IS TABLE OF VARCHAR2(32767) INDEX BY PLS_INTEGER;
    shared_strings_buffer shared_strings_buffer_type;
    
    TYPE sheet_data_buffer_type IS TABLE OF VARCHAR2(32767) INDEX BY PLS_INTEGER;
    sheet_data_buffer sheet_data_buffer_type;

    loaded_document BLOB := EMPTY_BLOB(); 
    loaded_shared_strings CLOB := EMPTY_CLOB(); 
    loaded_sheet CLOB := EMPTY_CLOB();
    
    TYPE cell_value_type IS RECORD(value VARCHAR2(32767),
                                   varchar2_value VARCHAR2(32767),
                                   number_value NUMBER,
                                   date_value DATE,
                                   type VARCHAR2(1));
    loaded_row_id INTEGER;
    loaded_row_string CLOB;
    TYPE loaded_styles_type IS TABLE OF VARCHAR2(1) INDEX BY PLS_INTEGER;
    loaded_styles loaded_styles_type;
    loaded_styles_empty loaded_styles_type;  
    loaded_date_system VARCHAR2(4);
    local_charset VARCHAR2(30);
    date_system INTEGER;
    
    /***************************************************************************
    * Description: Creates new instance of excel document, initializes space 
    *  storage and prepares parameters
    *
    * Input Parameters: 
    *   - no input parameters
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - doc_id [unique identifier of document]
    *
    ****************************************************************************/
    FUNCTION new_document 
    RETURN PLS_INTEGER;
    ----------------------------------------------------------------------------
    
    
    /***************************************************************************
    * Description: Wrapper procedure of new_document function
    *
    * Input Parameters: 
    *   - no input parameters
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/
    PROCEDURE new_document;
    ----------------------------------------------------------------------------
    
    
    /***************************************************************************
    * Description: Adds new sheet to document
    *
    * Input Parameters: 
    *   - sheet_name [sheet name that will be displayed on sheet tab]
    *   - doc_id     [unique identificator od document]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - sheet_id  [unique identificator of sheet within document]
    *
    ****************************************************************************/
    FUNCTION add_sheet(sheet_name VARCHAR2, 
                       doc_id PLS_INTEGER DEFAULT current_doc_id) 
    RETURN PLS_INTEGER;
    ----------------------------------------------------------------------------
    
    
    /***************************************************************************
    * Description: Wrapper procedure of add_sheet function
    *
    * Input Parameters: 
    *   - sheet_name [sheet name that will be displayed on sheet tab]
    *   - doc_id     [unique identificator of document]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/
    PROCEDURE add_sheet(sheet_name VARCHAR2, 
                        doc_id PLS_INTEGER DEFAULT current_doc_id);
    ----------------------------------------------------------------------------
         
                       
    /***************************************************************************
    * Description: Adds row to current or specified sheet
    *
    * Input Parameters: 
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - row_id    [unique identificator of row within specified sheed and document]
    *
    ****************************************************************************/
    FUNCTION add_row(doc_id PLS_INTEGER DEFAULT current_doc_id, 
                     sheet_id PLS_INTEGER DEFAULT current_sheet_id) RETURN PLS_INTEGER; 
    ----------------------------------------------------------------------------                     
         
                
    /***************************************************************************
    * Description: Wrapper procedure for add_row function
    *
    * Input Parameters: 
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                
    PROCEDURE add_row(doc_id PLS_INTEGER DEFAULT current_doc_id, 
                      sheet_id PLS_INTEGER DEFAULT current_sheet_id);
    ----------------------------------------------------------------------------                       
      
    
    /***************************************************************************
    * Description: Sets height of speficied row
    *
    * Input Parameters: 
    *   - height     [height of the row]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                 
    PROCEDURE set_row_height(height NUMBER, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id, 
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                             row_id PLS_INTEGER DEFAULT current_row_id); 
    ---------------------------------------------------------------------------- 
                                                      

    /***************************************************************************
    * Description: Sets value of numeric cell
    *
    * Input Parameters: 
    *   - name       [name of the cell where value will be added]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value NUMBER, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
         
                                
    /***************************************************************************
    * Description: Sets value of string cell
    *
    * Input Parameters: 
    *   - name       [name of the cell where value will be added]
    *   - value      [date value that will be set to the cell]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value VARCHAR2, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id); 
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets value of date cell
    *
    * Input Parameters: 
    *   - name       [name of the cell where value will be added]
    *   - value      [date value that will be set to the cell]
    *   - doc_id     [unique identificator of document
    *   - sheet_id   [unique identificator of sheet
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value DATE, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id); 
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets value of big string cell (CLOB)
    *
    * Input Parameters: 
    *   - name       [name of the cell where value will be added]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                  
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value CLOB, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id);  
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets format of the cell
    *
    * Input Parameters: 
    *   - cell_name  [name of the cell on which format will be applied]
    *   - format     [format mask that will be applied to the cell, same as custom format in Excel]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                                                              
    PROCEDURE set_cell_format (cell_name VARCHAR2, 
                               format VARCHAR2, 
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                               row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Generates Excel document and stores it in BLOB variable
    *
    * Input Parameters: 
    *   - blob_file  [BLOB variable where generated Excel will be stored]
    *   - doc_id     [unique identificator of document]
    *
    * Output Parameters: 
    *   - blob_file  [BLOB variable where generated Excel will be stored]
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                                                                                                                                                        
    PROCEDURE save_to_blob(blob_file IN OUT BLOB, 
                           doc_id PLS_INTEGER DEFAULT current_doc_id);                                              
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets font family of the cell
    *
    * Input Parameters: 
    *   - cell_name  [name of the cell on which format will be applied]
    *   - font_name  [font family which will be applied to the cell ex. Arial]
    *   - font_size  [size that will be applied to the font for specified cell]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_font(cell_name VARCHAR2, 
                            font_name VARCHAR2, 
                            font_size PLS_INTEGER DEFAULT 10, 
                            doc_id PLS_INTEGER DEFAULT current_doc_id, 
                            sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                            row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets default font family for whole document
    *
    * Input Parameters: 
    *   - font_name  [font family which will be applied to whole document ex. Arial]
    *   - font_size  [size that will be applied to the font for whole document]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_default_font (font_name VARCHAR2 DEFAULT 'Calibri', 
                                font_size PLS_INTEGER DEFAULT 11, 
                                doc_id PLS_INTEGER DEFAULT current_doc_id); 
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets cell type to bold
    *
    * Input Parameters: 
    *   - name       [name of cell which content will be bolded]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_bold(name VARCHAR2, 
                            doc_id PLS_INTEGER DEFAULT current_doc_id, 
                            sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                            row_id PLS_INTEGER DEFAULT current_row_id); 
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets cell stype to italic
    *
    * Input Parameters: 
    *   - name       [name of cell which content will be formated to italic]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_italic(name VARCHAR2, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                              row_id PLS_INTEGER DEFAULT current_row_id);                                                              
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets cell stype to underline
    *
    * Input Parameters: 
    *   - name       [name of cell which content will be underline]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_underline(name VARCHAR2, 
                                 doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                 sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                 row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets color of font within cell
    *
    * Input Parameters: 
    *   - name       [name of cell which font will be colored]
    *   - color      [font color in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                              
    PROCEDURE set_cell_color(name VARCHAR2, 
                             color VARCHAR2, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id, 
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                             row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets background color of cell
    *
    * Input Parameters: 
    *   - name       [name of cell which background will be colored]
    *   - color      [background color in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                                   
    PROCEDURE set_cell_bg_color(name VARCHAR2, 
                                color VARCHAR2, 
                                doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                row_id PLS_INTEGER DEFAULT current_row_id);   
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets left side horizontal alignement of cell 
    *
    * Input Parameters: 
    *   - name       [name of cell content will be placed to left side of column]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_align_left(name VARCHAR2, 
                                 doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                 sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                 row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets horizontal alignement of cell to center  
    *
    * Input Parameters: 
    *   - name       [name of cell content will be centered]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_align_center(name VARCHAR2, 
                                    doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                    row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets horizontal alignement of cell to right  
    *
    * Input Parameters: 
    *   - name       [name of cell content will be placed to right side of column]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_align_right(name VARCHAR2, 
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                              
    /***************************************************************************
    * Description: Sets vertical alignement of cell to top
    *
    * Input Parameters: 
    *   - name       [name of cell content will be placed to the top]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_vert_align_top(name VARCHAR2, 
                                      doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                      sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                      row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                    
    /***************************************************************************
    * Description: Sets vertical alignement of cell to middle
    *
    * Input Parameters: 
    *   - name       [name of cell content will be placed in the middle]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_vert_align_middle(name VARCHAR2, 
                                         doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                         sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                         row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Sets vertical alignement of cell to bottom
    *
    * Input Parameters: 
    *   - name       [name of cell content will be placed to the bottom]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_vert_align_bottom(name VARCHAR2, 
                                         doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                         sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                         row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
    
                                             
    /***************************************************************************
    * Description: Sets width of the column
    *
    * Input Parameters: 
    *   - name       [name of the column which width will be set to specified value]
    *   - width      [width of column]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_column_width(name VARCHAR2, 
                               width NUMBER, 
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Sets top border of the cell
    *
    * Input Parameters: 
    *   - name       [name of cell on which top border will be set]
    *   - style      [style of the border:  thin, thick, double]
    *   - color      [color of border in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_border_top(name VARCHAR2, 
                                  style VARCHAR2 DEFAULT 'thin', 
                                  color VARCHAR2 DEFAULT '00000000', 
                                  doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                  sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                  row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Sets bottom border of the cell
    *
    * Input Parameters: 
    *   - name       [name of cell on which bottom border will be set]
    *   - style      [style of the border:  thin, thick, double]
    *   - color      [color of border in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_border_bottom(name VARCHAR2, 
                                     style VARCHAR2 DEFAULT 'thin', 
                                     color VARCHAR2 DEFAULT '00000000', 
                                     doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                     sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                     row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Sets left border of the cell
    *
    * Input Parameters: 
    *   - name       [name of cell on which left border will be set]
    *   - style      [style of the border:  thin, thick, double]
    *   - color      [color of border in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_border_left(name VARCHAR2, 
                                   style VARCHAR2 DEFAULT 'thin', 
                                   color VARCHAR2 DEFAULT '00000000', 
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Sets right border of the cell
    *
    * Input Parameters: 
    *   - name       [name of cell on which right border will be set]
    *   - style      [style of the border:  thin, thick, double]
    *   - color      [color of border in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_border_right(name VARCHAR2, 
                                    style VARCHAR2 DEFAULT 'thin', 
                                    color VARCHAR2 DEFAULT '00000000', 
                                    doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                    row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Sets border of the cell
    *
    * Input Parameters: 
    *   - name       [name of cell on which border will be set]
    *   - style      [style of the border:  thin, thick, double]
    *   - color      [color of border in RRGGBB hex format RR - red, GG - green, BB blue]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_border(name VARCHAR2, 
                              style VARCHAR2 DEFAULT 'thin', 
                              color VARCHAR2 DEFAULT '00000000', 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                              row_id PLS_INTEGER DEFAULT current_row_id);                                 
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Fetches data with speified query and place results on specified
    * or current sheet
    *
    * Input Parameters: 
    *   - query             [SQL query whih result will be added to sheet]
    *   - show_column_names [parameter to hide or show column names from SQL query, boolean values TRUE or FALSE]    
    *   - doc_id            [unique identificator of document]
    *   - sheet_id          [unique identificator of sheet]    
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                        
    PROCEDURE query_to_sheet(query CLOB, 
                             show_column_names BOOLEAN DEFAULT TRUE, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id, 
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id);                                                              
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Generates Excel document and saves it to physical file in Oracle directory
    *
    * Input Parameters: 
    *   - directory_name [name of Oracle directory where Excel document will be saved]
    *   - file_name      [file name of generated Excel document]
    *   - doc_id         [unique identificator of document]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE save_to_file(directory_name VARCHAR2, 
                           file_name VARCHAR2, 
                           doc_id PLS_INTEGER DEFAULT current_doc_id);   
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Merges cells horizontaly within specified range
    *
    * Input Parameters: 
    *   - cell_from  [name of cell from merge will be started, name example: A1]
    *   - cell_to    [name of cell to where merge will finis, name example: C1]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE merge_cells (cell_from VARCHAR2, 
                           cell_to VARCHAR2, 
                           doc_id PLS_INTEGER DEFAULT current_doc_id, 
                           sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                           row_id PLS_INTEGER DEFAULT current_row_id);                                                                                                                                                        
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Wraps text within cell
    *
    * Input Parameters: 
    *   - name       [name of cell which text will be wrapped]
    *   - doc_id     [unique identificator of document on which is located sheet 
    *                 where is lcaterd row with cell which conted will be wrapped]
    *   - sheet_id   [unique identificator of sheet on which is located row
    *                 row with cell which conted will be wrapped]
    *   - row_id     [unique identificator of row on which cell will be merged]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_wrap_text (name VARCHAR2, 
                                  doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                  sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                  row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
                                   
                                                                       
    /***************************************************************************
    * Description: Merges cells vertically within specified range
    *
    * Input Parameters: 
    *   - cell_from  [name of cell from merge will be started, name example: A1]
    *   - cell_to    [name of cell to where merge will finis, name example: C1]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE merge_rows (cell_from VARCHAR2, 
                          cell_to PLS_INTEGER, 
                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                          sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                          row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
    
                                                                
    /***************************************************************************
    * Description: Sets cell formula
    *
    * Input Parameters: 
    *   - name       [name of the cell where value will be added]
    *   - formula    [formula that will be used to calculate cell value]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
        PROCEDURE set_cell_formula(name VARCHAR2, 
                                  formula VARCHAR2, 
                                  doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                  sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                                  row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------  
                                   
                              
    /***************************************************************************
    * Description: Rotates text to a diagonal angle
    *
    * Input Parameters: 
    *   - name       [name of cell content will be centered]
    *   - degrees    [degree from 90 to 180 which will be used to rotate text]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_rotate_text(name VARCHAR2,
                                   degrees INTEGER, 
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------
    
                                        
    /***************************************************************************
    * Description: Initiates download of generated excel file using DAD
    *
    * Input Parameters: 
    *   - file_name      [file name that will be suggested when download dialog appears]
    *   - doc_id         [unique identificator of document]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE download_file(file_name VARCHAR2, 
                            doc_id PLS_INTEGER DEFAULT current_doc_id);   
    ----------------------------------------------------------------------------     
    
    
    /***************************************************************************
    * Description: Sets margins of sheet
    *
    * Input Parameters: 
    *   - left_margin     [margin size on the left side of sheet]
    *   - right_margin    [margin size on the right side of sheet]
    *   - top_margin      [margin size on the top side of sheet]
    *   - bottom_margin   [margin size on the bottom side of sheet]
    *   - header_margin   [margin size on the header side of sheet]
    *   - footer_margin   [margin size on the footer side of sheet]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_sheet_margins(left_margin NUMBER,
                                right_margin NUMBER, 
                                top_margin NUMBER,
                                bottom_margin NUMBER,
                                header_margin NUMBER,
                                footer_margin NUMBER, 
                                sheet_id PLS_INTEGER DEFAULT current_sheet_id);
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Sets sheet orientation to landscape
    *
    * Input Parameters: 
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_sheet_landscape(sheet_id PLS_INTEGER DEFAULT current_sheet_id); -- New
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Sets sheet paper size
    *
    * Input Parameters: 
    *   - paper_size [paper size of sheet]
    *                Possible values: 
    *                   1 - Letter (8-1/2 in. x 11 in.)
    *                   2 - Letter Small (8-1/2 in. x 11 in.)
    *                   3 - Tabloid (11 in. x 17 in.)
    *                   4 - Ledger (17 in. x 11 in.)
    *                   5 - Legal (8-1/2 in. x 14 in.)
    *                   6 - Statement (5-1/2 in. x 8-1/2 in.)
    *                   7 - Executive (7-1/2 in. x 10-1/2 in.)
    *                   8 - A3 (297 mm x 420 mm)
    *                   9 - A4 (210 mm x 297 mm)
    *                   10 - A4 Small (210 mm x 297 mm)
    *                   11 - A5 (148 mm x 210 mm)
    *                   12 - B4 (250 mm x 354 mm)
    *                   13 - A5 (148 mm x 210 mm)
    *                   14 - Folio (8-1/2 in. x 13 in.)
    *                   15 - Quarto (215 mm x 275 mm)
    *                   16 - 10 in. x 14 in.
    *                   17 - 11 in. x 17 in.
    *                   18 - Note (8-1/2 in. x 11 in.)
    *                   19 - Envelope #9 (3-7/8 in. x 8-7/8 in.)
    *                   20 - Envelope #10 (4-1/8 in. x 9-1/2 in.)
    *                   21 - Envelope #11 (4-1/2 in. x 10-3/8 in.)
    *                   22 - Envelope #12 (4-1/2 in. x 11 in.)
    *                   23 - Envelope #14 (5 in. x 11-1/2 in.)
    *                   24 - C size sheet
    *                   25 - D size sheet
    *                   26 - E size sheet
    *                   27 - Envelope DL (110 mm x 220 mm)
    *                   28 - Envelope C5 (162 mm x 229 mm)
    *                   29 - Envelope C3 (324 mm x 458 mm)
    *                   30 - Envelope C4 (229 mm x 324 mm)
    *                   31 - Envelope C6 (114 mm x 162 mm)
    *                   32 - Envelope C65 (114 mm x 229 mm)
    *                   33 - Envelope B4 (250 mm x 353 mm)
    *                   34 - Envelope B5 (176 mm x 250 mm)
    *                   35 - Envelope B6 (176 mm x 125 mm)
    *                   36 - Envelope (110 mm x 230 mm)
    *                   37 - Envelope Monarch (3-7/8 in. x 7-1/2 in.)
    *                   38 - Envelope (3-5/8 in. x 6-1/2 in.)
    *                   39 - U.S. Standard Fanfold (14-7/8 in. x 11 in.)
    *                   40 - German Legal Fanfold (8-1/2 in. x 13 in.)
    *                   41 - German Legal Fanfold (8-1/2 in. x 13 in.)
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_sheet_paper_size(paper_size INTEGER, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id);
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Sets sheet header text
    *
    * Input Parameters: 
    *   - header_text [text that will be displayed on sheets header, limited to 1000 characters]
    *   - sheet_id    [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_sheet_header_text(header_text VARCHAR2,
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id); -- New
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Sets sheet footer text
    *
    * Input Parameters: 
    *   - header_text [text that will be displayed on sheets footer, limited to 1000 characters]
    *   - sheet_id    [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_sheet_footer_text(footer_text VARCHAR2,
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id); -- New   
    ----------------------------------------------------------------------------                                        

    /***************************************************************************
    * Description: Sets hyperlink for cell
    *
    * Input Parameters: 
    *   - name       [cell name]
    *   - hyperlink  [hyperlink that will be set on cell]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                 
    PROCEDURE set_cell_hyperlink(name VARCHAR2, 
                                 hyperlink VARCHAR2,
                                 doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                 sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                 row_id PLS_INTEGER DEFAULT current_row_id); 
    ---------------------------------------------------------------------------- 

    /***************************************************************************
    * Description: Sets hyperlink within document, to same or another sheet and 
    *              to cell within sheet
    *
    * Input Parameters: 
    *   - name       [cell name]
    *   - hyperlink  [hyperlink that will be set on cell, example Sheet1!A1 will
    *                 link to sheet with name Sheet1 and to cell A1 within that
    *                 sheet - if sheet name containst spaces it must be enclosed
    *                 with sigle quotes example: '''My Sheet1''!A1' ]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                 
    PROCEDURE set_cell_internal_hyperlink(name VARCHAR2, 
                                          hyperlink VARCHAR2,
                                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                          sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                          row_id PLS_INTEGER DEFAULT current_row_id); 
    ---------------------------------------------------------------------------- 
                                         
    /***************************************************************************
    * Description: Sets left indent within the cell
    *
    * Input Parameters: 
    *   - name       [name of cell content will be indented from the left side]
    *   - indent     [number of indent from left site of cell]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_indent_left(name VARCHAR2, 
                                   indent INTEGER,
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id);
    ----------------------------------------------------------------------------                                                                                            
    
    /***************************************************************************
    * Description: Sets right indent within the cell
    *
    * Input Parameters: 
    *   - name       [name of cell content will be indented from the right side]
    *   - indent     [number of indent from left site of cell]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE set_cell_indent_right(name VARCHAR2, 
                                   indent INTEGER,
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id);
    ---------------------------------------------------------------------------- 
    
    /***************************************************************************
    * Description: Sets comment text and author name for cell
    *
    * Input Parameters: 
    *   - name                [cell name]
    *   - author              [name of the autor of the comment]
    *   - comment_text        [comment text for the cell]
    *   - comment_box_width   [width of comment box]
    *   - comment_box_height  [height of comment box]
    *   - doc_id              [unique identificator of document]
    *   - sheet_id            [unique identificator of sheet]
    *   - row_id              [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                 
    PROCEDURE set_cell_comment(name VARCHAR2, 
                               autohr VARCHAR2,
                               comment_text VARCHAR2,
                               comment_box_width NUMBER DEFAULT 100,
                               comment_box_height NUMBER DEFAULT 60,
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                               row_id PLS_INTEGER DEFAULT current_row_id); 
    ---------------------------------------------------------------------------- 
    
    /***************************************************************************
    * Description: Hides column
    *
    * Input Parameters: 
    *   - name       [name of the column which will be hidden]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE hide_column(name VARCHAR2,  
                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                          sheet_id PLS_INTEGER DEFAULT current_sheet_id);
    ----------------------------------------------------------------------------
    
    /***************************************************************************
    * Description: Hides row
    *
    * Input Parameters: 
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *   - row_id     [unique identificator of row]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                 
    PROCEDURE hide_row(doc_id PLS_INTEGER DEFAULT current_doc_id, 
                       sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                       row_id PLS_INTEGER DEFAULT current_row_id); 
    ---------------------------------------------------------------------------- 
    
    /***************************************************************************
    * Description: Sets column auto filter between defined columns range
    *
    * Input Parameters: 
    *   - cell_from  [cell name with row number from which auto filter will start, example: A1]
    *   - cell_to    [cell name with row number where auto filter will end, example: A5]
    *   - doc_id     [unique identificator of document]
    *   - sheet_id   [unique identificator of sheet]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/    
    PROCEDURE set_cells_filter(cell_from VARCHAR2, 
                              cell_to VARCHAR2,
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id); 
    ---------------------------------------------------------------------------- 
    
    /***************************************************************************
    * Description: Opens Excel file for reading
    *
    * Input Parameters: 
    *   - directory_name [name of Oracle directory from where Excel document will be opened]
    *   - file_name      [file name of Excel document]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/      
     PROCEDURE open_document(directory_name VARCHAR2, 
                             file_name VARCHAR2);
    ---------------------------------------------------------------------------- 
    
    /***************************************************************************
    * Description: Release memory for currently opened document
    *
    * Input Parameters:
    *   - no imput parameters 
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/      
     PROCEDURE close_document;
    ----------------------------------------------------------------------------     
    
    /***************************************************************************
    * Description: Loads sheet from opened document
    *
    * Input Parameters:
    *   - sheet_name - [name of sheet case isensitive]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/      
    PROCEDURE open_sheet(sheet_name VARCHAR2);
    ---------------------------------------------------------------------------- 
    
    /***************************************************************************
    * Description: Loads sheet from opened document
    *
    * Input Parameters:
    *   - sheet_id - [numberic index od sheet (ex. 1 = first sheet, 2 = second sheet ...)]
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/      
    PROCEDURE open_sheet(sheet_id PLS_INTEGER);
    ----------------------------------------------------------------------------

    /***************************************************************************
    * Description: Returns cell value
    *
    * Input Parameters:
    *   - cell_name - [cell name which conted will be returned (ex. A1)] 
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - cell value type
    *       - varchar2_value  - cell value converted to varchar2 type 
    *       - varchar2_number - cell value converted to number type
    *       - varchar2_date   - cell value converted to date type
    *
    ****************************************************************************/      
    
    FUNCTION get_cell_value(cell_name VARCHAR2) RETURN cell_value_type;
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Returns last row number from loaded sheet
    *
    * Input Parameters:
    *   - no input parameters
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - last row number
    *
    ****************************************************************************/ 
    FUNCTION get_last_row RETURN INTEGER;
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Set 1904 date system, the first day that is supported is 
    *              January 1, 1904
    *
    * Input Parameters:
    *   - no input parameters
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/     
    PROCEDURE set_1904_date_system;
    ----------------------------------------------------------------------------  
    
    /***************************************************************************
    * Description: Set 1900 date system, the first day that is supported is 
    *              January 1, 1900
    *
    * Input Parameters:
    *   - no input parameters
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/     
    PROCEDURE set_1900_date_system;
    
    /***************************************************************************
    * Description: Set document author property to custom value
    *
    * Input Parameters:
    *   - author - author name
    *   - doc_id - unique identificator of document
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/      
    
    PROCEDURE set_document_author(author VARCHAR2, doc_id PLS_INTEGER DEFAULT current_doc_id);
              
    
    /***************************************************************************
    * Description: Add style to current docuemnt
    *
    * Input Parameters:
    *   - style_name            - style name used as referece to apply to cell
    *   - font_name             - font name examples: 'Tahoma', 'Arial', 'Times New Roman'
    *   - font_size             - font size, default 11
    *   - formula               - cell formula
    *   - bold                  - bold cell content
    *   - italic                - italic cell content
    *   - underline             - underline cell content
    *   - color                 - text color in hex, example: red = FF0000
    *   - bg_color              - cell background color in hex, example: grey = CCCCCC
    *   - horizontal_align      - horizontal text alignment, values: 'left', 'center', 'right'
    *   - vertical_align        - vertical text alignment, value: 'top', 'middle', 'bottom'
    *   - border_top            - show cell top border, values: TRUE, FALSE
    *   - border_top_style      - top border style, values: 'thin', 'thick', 'double'
    *   - border_top_color      - top border color in hex, example green = 00FF00
    *   - border_bottom         - show cell bottom border, values: TRUE, FALSE
    *   - border_bottom_style   - bottom border style, values: 'thin', 'thick', 'double'
    *   - border_bottom_color   - bottom border color in hex, example green = 00FF00
    *   - border_left           - show cell left border, values: TRUE, FALSE
    *   - border_left_style     - left border style, values: 'thin', 'thick', 'double'
    *   - border_left_color     - left border color in hex, example green = 00FF00
    *   - border_right          - show cell right border, values: TRUE, FALSE
    *   - border_right_style    - right border style, values: 'thin', 'thick', 'double'
    *   - border_right_color    - right border color in hex, example green = 00FF00
    *   - border                - show all cell borders, values: TRUE, FALSE
    *   - border_style          - all cell borders style, values: 'thin', 'thick', 'double'
    *   - border_color          - all cell borders color in hex, example green = 00FF00
    *   - wrap_text             - wrap text within cell, values: TRUE, FALSE
    *   - format                - format mas for cell
    *   - rotate_text_degree    - degree number for text rotation, values from 0 to 360
    *   - indent_left           - number of indents from left side, values: number greather than zero
    *   - indent_right          - Number of indents from right side, values: number greather than zero
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/            
    PROCEDURE add_style (style_name VARCHAR2,
                         font_name VARCHAR2 DEFAULT NULL,
                         font_size PLS_INTEGER DEFAULT NULL,
                         formula VARCHAR2 DEFAULT NULL,
                         bold BOOLEAN DEFAULT FALSE,
                         italic BOOLEAN DEFAULT FALSE,
                         underline BOOLEAN DEFAULT FALSE,
                         color VARCHAR2 DEFAULT NULL,
                         bg_color VARCHAR2 DEFAULT NULL,
                         horizontal_align VARCHAR2 DEFAULT NULL,
                         vertical_align VARCHAR2 DEFAULT NULL,
                         border_top BOOLEAN DEFAULT FALSE,
                         border_top_style VARCHAR2 DEFAULT NULL,
                         border_top_color VARCHAR2 DEFAULT NULL,
                         border_bottom BOOLEAN DEFAULT FALSE,
                         border_bottom_style VARCHAR2 DEFAULT NULL,
                         border_bottom_color VARCHAR2 DEFAULT NULL,
                         border_left BOOLEAN DEFAULT FALSE,
                         border_left_style VARCHAR2 DEFAULT NULL,
                         border_left_color VARCHAR2 DEFAULT NULL,
                         border_right BOOLEAN DEFAULT FALSE,
                         border_right_style VARCHAR2 DEFAULT NULL,
                         border_right_color VARCHAR2 DEFAULT NULL,
                         border BOOLEAN DEFAULT NULL,
                         border_style VARCHAR2 DEFAULT NULL,
                         border_color VARCHAR2 DEFAULT NULL,
                         wrap_text BOOLEAN DEFAULT FALSE,
                         format VARCHAR2 DEFAULT NULL,
                         rotate_text_degree INTEGER DEFAULT NULL,
                         indent_left INTEGER DEFAULT NULL,
                         indent_right INTEGER DEFAULT NULL,
                         doc_id PLS_INTEGER DEFAULT current_doc_id);
        
    /***************************************************************************
    * Description: Appliest predefined style to cell
    *
    * Input Parameters:
    *   - cell_name  - name of cell, example 'A'
    *   - style_name - name of style defined with procedure add_style
    *   - doc_id     - unique identificator of document
    *   - sheet_id   - unique identificator of sheet
    *   - row_id     - unique identificator of row
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/      
                     
    PROCEDURE set_cell_style(cell_name VARCHAR2, 
                             style_name VARCHAR2, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id,
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                             row_id PLS_INTEGER DEFAULT current_row_id);   	

	/***************************************************************************
    * Description: Freeze panes horizontally
    *
    * Input Parameters:
    *   - freeze_columns_number  - top left column name with row number, 
    *                              example: to freeze first row set 'A2' as top 
    *                              left row
    *   - doc_id                 - unique identificator of document
    *   - sheet_id               - unique identificator of sheet
    *   - row_id                 - unique identificator of row
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/                         
    PROCEDURE freeze_panes_horizontal(freeze_columns_number VARCHAR2,
                                      doc_id PLS_INTEGER DEFAULT current_doc_id,
                                      sheet_id PLS_INTEGER DEFAULT current_sheet_id);
                          
     
    
    /***************************************************************************
    * Description: Freeze panes vertically
    *
    * Input Parameters:
    *   - freeze_rows_number  - top left column name with row number, example: 
    *                           to freeze first column set 1 as top left row
    *   - doc_id              - unique identificator of document
    *   - sheet_id            - unique identificator of sheet
    *   - row_id              - unique identificator of row
    *
    * Output Parameters: 
    *   - no output parameters
    *
    * Returns:
    *   - does not return anything
    *
    ****************************************************************************/ 
    PROCEDURE freeze_panes_vertical(freeze_rows_number VARCHAR2,
                                    doc_id PLS_INTEGER DEFAULT current_doc_id,
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id); 
                                                                                                                           
END ORA_EXCEL;

/
CREATE OR REPLACE PACKAGE BODY PLPDF.ORA_EXCEL IS

    PROCEDURE print_clob (p_clob IN CLOB, filename VARCHAR2)
    AS
       l_offset   NUMBER DEFAULT 1;
    BEGIN
       RETURN;
       dbms_output.put_line(filename); 
       LOOP
          EXIT WHEN l_offset > DBMS_LOB.getlength (p_clob);
          DBMS_OUTPUT.put_line (DBMS_LOB.SUBSTR (p_clob, 255, l_offset));
          l_offset := l_offset + 255;
       END LOOP;
          
    END;
    ----------------------------------------------------------------------------
     
    PROCEDURE append_to_clob(clob_variable IN OUT NOCOPY CLOB, 
                             line VARCHAR2) 
    IS
    BEGIN
        dbms_lob.writeappend(clob_variable, LENGTH(line), line);
    END;   
    ----------------------------------------------------------------------------
    
    FUNCTION column_numeric2alpha (p_col PLS_INTEGER)
       RETURN VARCHAR2
    IS
    BEGIN
                
        IF cache_column_alpha_in = p_col THEN
            RETURN cache_column_alpha_out;
        END IF;
                
        
        cache_column_alpha_out :=  CASE
                                     WHEN p_col > 702
                                     THEN
                                           CHR (64 + TRUNC ( (p_col - 27) / 676))
                                        || CHR (65 + MOD (TRUNC ( (p_col - 1) / 26) - 1, 26))
                                        || CHR (65 + MOD (p_col - 1, 26))
                                     WHEN p_col > 26
                                     THEN
                                        CHR (64 + TRUNC ( (p_col - 1) / 26))
                                        || CHR (65 + MOD (p_col - 1, 26))
                                     ELSE
                                        CHR (64 + p_col)
                                  END;
        cache_column_alpha_in := p_col;
        
        RETURN cache_column_alpha_out;
                                          
    END;
    ----------------------------------------------------------------------------

    FUNCTION column_alpha2numeric (p_col VARCHAR2)
       RETURN PLS_INTEGER
    IS
    BEGIN

        IF cache_column_number_in = UPPER(p_col) THEN
            RETURN cache_column_number_out;
        END IF;
        
        cache_column_number_in := UPPER(p_col);
        
        cache_column_number_out := ASCII (SUBSTR (cache_column_number_in, -1))
                                  - 64
                                  + NVL ( (ASCII (SUBSTR (cache_column_number_in, -2, 1)) - 64) * 26, 0)
                                  + NVL ( (ASCII (SUBSTR (cache_column_number_in, -3, 1)) - 64) * 676, 0);
        
                
        RETURN cache_column_number_out;
                              
    END;
    ----------------------------------------------------------------------------

    FUNCTION add_fill (fill fills_type, doc_id PLS_INTEGER) RETURN NUMBER IS 
       fill_id PLS_INTEGER;
    BEGIN
        -- Check if string exists
        IF documents(doc_id).fills.LAST IS NOT NULL THEN
            FOR i IN documents(doc_id).fills.FIRST .. documents(doc_id).fills.LAST LOOP
                IF documents(doc_id).fills(i).pattern_type = fill.pattern_type AND
                   documents(doc_id).fills(i).color = fill.color
                THEN
                    IF i > 1 THEN
                        RETURN i - 1;
                    ELSE
                        RETURN i;
                    END IF;
                END IF;
            END LOOP;
        END IF;
 
        -- If string not exists add to list
        documents(doc_id).fills.EXTEND;
        fill_id := documents(doc_id).fills.LAST;
        
        documents(doc_id).fills(fill_id).pattern_type := fill.pattern_type;
        documents(doc_id).fills(fill_id).color := fill.color;

        IF fill_id > 1 THEN
            RETURN fill_id - 1;
        ELSE
            RETURN fill_id;
        END IF; 
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION add_border (border borders_type, doc_id PLS_INTEGER) RETURN NUMBER IS
       border_id PLS_INTEGER;
    BEGIN
        -- Check if string exists
        IF documents(doc_id).borders.LAST IS NOT NULL THEN
            FOR i IN documents(doc_id).borders.FIRST .. documents(doc_id).borders.LAST LOOP
                IF documents(doc_id).borders(i).border_top = border.border_top AND
                   documents(doc_id).borders(i).border_top_style = border.border_top_style AND
                   documents(doc_id).borders(i).border_top_color = border.border_top_color AND
                   documents(doc_id).borders(i).border_bottom = border.border_bottom AND
                   documents(doc_id).borders(i).border_bottom_style = border.border_bottom_style AND
                   documents(doc_id).borders(i).border_bottom_color = border.border_bottom_color AND
                   documents(doc_id).borders(i).border_left = border.border_left AND
                   documents(doc_id).borders(i).border_left_style = border.border_left_style AND
                   documents(doc_id).borders(i).border_left_color = border.border_left_color AND
                   documents(doc_id).borders(i).border_right = border.border_right AND
                   documents(doc_id).borders(i).border_right_style = border.border_right_style AND
                   documents(doc_id).borders(i).border_right_color = border.border_right_color AND
                   NVL(documents(doc_id).borders(i).border_color, '*') = NVL(border.border_color, '*') AND
                   NVL(documents(doc_id).borders(i).border_style, '*') = NVL(border.border_style, '*')
                THEN

                    IF i > 0 THEN
                        RETURN i - 1;
                    ELSE
                        RETURN i;
                    END IF;

                END IF;
            END LOOP;
        END IF;
        
        documents(doc_id).borders.EXTEND;
        border_id := documents(doc_id).borders.LAST;
        
        documents(doc_id).borders(border_id).border_top := NVL(border.border_top, FALSE);
        documents(doc_id).borders(border_id).border_top_style := NVL(border.border_top_style, 'thin');
        documents(doc_id).borders(border_id).border_top_color := NVL(border.border_top_color, '00000000');
        documents(doc_id).borders(border_id).border_bottom :=  NVL(border.border_bottom, FALSE);
        documents(doc_id).borders(border_id).border_bottom_style :=  NVL(border.border_bottom_style, 'thin');
        documents(doc_id).borders(border_id).border_bottom_color :=  NVL(border.border_bottom_color, '00000000');
        documents(doc_id).borders(border_id).border_left :=  NVL(border.border_left, FALSE);
        documents(doc_id).borders(border_id).border_left_style :=  NVL(border.border_left_style, 'thin');
        documents(doc_id).borders(border_id).border_left_color :=  NVL(border.border_left_color, '00000000');
        documents(doc_id).borders(border_id).border_right :=  NVL(border.border_right, FALSE);
        documents(doc_id).borders(border_id).border_right_style :=  NVL(border.border_right_style, 'thin');
        documents(doc_id).borders(border_id).border_right_color :=  NVL(border.border_right_color, '000000');
        documents(doc_id).borders(border_id).border_color := border.border_color;
        documents(doc_id).borders(border_id).border_style := border.border_style;

        IF border_id > 0 THEN
            RETURN border_id - 1;
        ELSE
            RETURN border_id;
        END IF; 

    END;
    ----------------------------------------------------------------------------
    
    FUNCTION add_format (format formats_type, doc_id PLS_INTEGER) RETURN NUMBER IS 
        last_id PLS_INTEGER;
    BEGIN
        -- Check if string exists
        IF documents(doc_id).formats.LAST IS NOT NULL THEN
            FOR i IN documents(doc_id).formats.FIRST .. documents(doc_id).formats.LAST LOOP
                IF documents(doc_id).formats(i).num_fmt_id = format.num_fmt_id AND
                   documents(doc_id).formats(i).font_id = format.font_id AND 
                   documents(doc_id).formats(i).fill_id = format.fill_id AND 
                   documents(doc_id).formats(i).border_id = format.border_id AND 
                   documents(doc_id).formats(i).xf_id = format.xf_id AND 
                   NVL(documents(doc_id).formats(i).horizontal_align, '*') = NVL(format.horizontal_align, '*') AND 
                   NVL(documents(doc_id).formats(i).vertical_align, '*') = NVL(format.vertical_align, '*') AND 
                   NVL(documents(doc_id).formats(i).wrap_text, FALSE) = NVL(format.wrap_text, FALSE) AND 
                   NVL(documents(doc_id).formats(i).rotate_text_degree, 0) = NVL(format.rotate_text_degree, 0) AND 
                   NVL(documents(doc_id).formats(i).indent_left, 0) = NVL(format.indent_left, 0) AND 
                   NVL(documents(doc_id).formats(i).indent_right, 0) = NVL(format.indent_right, 0) 
                THEN
                    RETURN i - 1;  -- First format is format with index 1, format with index 0 is default format
                END IF;
                
            END LOOP;
        END IF;
        -- If format not exists add to list
        documents(doc_id).formats.EXTEND;
        last_id := documents(doc_id).formats.LAST;
        
        documents(doc_id).formats(last_id).num_fmt_id := format.num_fmt_id;
        documents(doc_id).formats(last_id).font_id := format.font_id; 
        documents(doc_id).formats(last_id).fill_id := format.fill_id; 
        documents(doc_id).formats(last_id).border_id := format.border_id; 
        documents(doc_id).formats(last_id).xf_id := format.xf_id; 
        documents(doc_id).formats(last_id).horizontal_align := format.horizontal_align; 
        documents(doc_id).formats(last_id).wrap_text := format.wrap_text; 
        documents(doc_id).formats(last_id).vertical_align := format.vertical_align; 
        documents(doc_id).formats(last_id).rotate_text_degree := format.rotate_text_degree; 
        documents(doc_id).formats(last_id).indent_left := format.indent_left; 
        documents(doc_id).formats(last_id).indent_right := format.indent_right; 
        
        RETURN last_id - 1;
        
    END;
    ----------------------------------------------------------------------------
    
    
        FUNCTION add_font(font fonts_type, 
                      font_id PLS_INTEGER DEFAULT NULL, 
                      doc_id PLS_INTEGER) RETURN NUMBER 
    IS
        last_id PLS_INTEGER;
        font_name VARCHAR2(100);
        font_size PLS_INTEGER;
    BEGIN

        -- font name from parameter
        IF font.font_name IS NOT NULL THEN   
            font_name := font.font_name; 
            
        -- font name from set_cell_font
        ELSIF NVL(font_id, 0) > 0 AND NVL(documents(doc_id).fonts.LAST, 0) >= NVL(font_id, 0) AND documents(doc_id).fonts(font_id).font_name IS NOT NULL THEN 

            font_name := documents(doc_id).fonts(font_id).font_name; 
            
        -- default font name  
        ELSE
            font_name :=  documents(doc_id).default_font.font_name; 
        END IF;
             
        -- font size from parameter
        IF font.font_size IS NOT NULL THEN 
            font_size := font.font_size; 
            
        -- font size from set_cell_font
        ELSIF NVL(font_id, 0) > 0 AND NVL(documents(doc_id).fonts.LAST, 0) >= NVL(font_id, 0) AND documents(doc_id).fonts(font_id).font_size IS NOT NULL THEN 
            font_size := documents(doc_id).fonts(font_id).font_size; 
              
        -- default font size  
        ELSE
            font_size :=  documents(doc_id).default_font.font_size; 
        END IF;         

        -- Check if font exists
        IF documents(doc_id).fonts.LAST IS NOT NULL THEN

            FOR i IN documents(doc_id).fonts.FIRST .. documents(doc_id).fonts.LAST LOOP

                IF documents(doc_id).fonts(i).font_name = font_name AND 
                   documents(doc_id).fonts(i).font_size = font_size AND 
                   NVL(documents(doc_id).fonts(i).bold, FALSE) = NVL(font.bold, FALSE) AND 
                   NVL(documents(doc_id).fonts(i).italic, FALSE) = NVL(font.italic, FALSE) AND 
                   NVL(documents(doc_id).fonts(i).underline, FALSE) = NVL(font.underline, FALSE) AND 
                   NVL(documents(doc_id).fonts(i).color, '*') = NVL(font.color, '*') 
                THEN 
                    RETURN i; 
                END IF;
                       
            END LOOP;

        END IF;
            
        -- If format not exists add to list
        documents(doc_id).fonts.EXTEND;
        last_id := documents(doc_id).fonts.LAST;

        documents(doc_id).fonts(last_id).font_name := font_name; 
        documents(doc_id).fonts(last_id).font_size := font_size; 
        documents(doc_id).fonts(last_id).bold := font.bold; 
        documents(doc_id).fonts(last_id).italic := font.italic; 
        documents(doc_id).fonts(last_id).underline := font.underline; 
        documents(doc_id).fonts(last_id).color := font.color; 
                
        RETURN last_id; 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Function add_font'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    
    PROCEDURE prepare_cell_format(cell_name VARCHAR2, doc_id PLS_INTEGER DEFAULT current_doc_id, sheet_id PLS_INTEGER DEFAULT current_sheet_id) 
    IS
        format formats_type; 
        font fonts_type; 
        fill fills_type; 
        border borders_type;
        format_id PLS_INTEGER;
        format_string VARCHAR2(100);
        prepare_row_id INTEGER;
        formula VARCHAR2(4000);
    BEGIN
        
        prepare_row_id := REGEXP_SUBSTR(cell_name, '[[:digit:]+].*');
        current_cell_number := column_alpha2numeric(REGEXP_SUBSTR(cell_name, '[[:alpha:]+]*'));
        
        IF cell_formatted = TRUE THEN

            -- Default format values
            format.num_fmt_id := 0;
            format.font_id := 0; 
            format.fill_id := 0; 
            format.border_id := 0; 
            format.xf_id := 0; 
            format.horizontal_align := NULL; 
            format.wrap_text := FALSE; 
            format.vertical_align := NULL; 
            format_id := add_format(format, doc_id); 

            IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_type = 'D' AND NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_num_fmt_id, 0) = 0 THEN 
                format.num_fmt_id := 14; -- 14 m/d/yyyy
            ELSE
                format.num_fmt_id := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_num_fmt_id, 0); 
            END IF;

            -- Default font id, or font which is set by set_cell_font
            format.font_id := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_font_id, 0); 
            
            -- Bold, Italic, underline, change  font id
            IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).bold = TRUE OR 
               documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).italic = TRUE OR 
               documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).underline = TRUE OR 
               documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).color IS NOT NULL 
            THEN 
                font.font_size := NULL; 
                font.font_name := NULL; 
                font.italic := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).italic; 
                font.underline := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).underline; 
                font.bold := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).bold; 
                font.color := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).color; 
                format.font_id := NVL(add_font(font, format.font_id, doc_id) , 0); 
            END IF;

            format.fill_id := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_fill_id, 0);
                                        
            IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).bg_color IS NOT NULL THEN 
                fill.pattern_type := 'solid';
                fill.color := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).bg_color; 
                format.fill_id := NVL(add_fill(fill, doc_id), 0); 
            END IF;

            format.border_id := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_border_id, 0); 
                                        
            IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_top = TRUE OR 
               documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_bottom = TRUE OR 
               documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_left = TRUE OR 
               documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_right = TRUE   
            THEN
                border.border_top := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_top, FALSE); 
                border.border_top_style := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_top_style, 'thin'); 
                border.border_top_color := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_top_color, '00000000'); 
                                            
                border.border_bottom := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_bottom, FALSE); 
                border.border_bottom_style := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_bottom_style, 'thin'); 
                border.border_bottom_color := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_bottom_color, '00000000'); 
                                            
                border.border_left := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_left, FALSE); 
                border.border_left_style := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_left_style, 'thin'); 
                border.border_left_color := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_left_color, '00000000'); 
                                            
                border.border_right := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_right, FALSE); 
                border.border_right_style := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_right_style, 'thin'); 
                border.border_right_color := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_right_color, '00000000'); 
                                            
                border.border_style := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_style; 
                border.border_color := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).border_color; 
                                            
                format.border_id := NVL(add_border(border, doc_id), 0); 
            END IF;

            format.xf_id := NVL(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_xf_id, 0); 
            format.horizontal_align := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).horizontal_align; 
            format.wrap_text :=documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).wrap_text; 
            format.vertical_align := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).vertical_align;   
            format.rotate_text_degree := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).rotate_text_degree; 
            format.indent_left := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).indent_left;  
            format.indent_right := documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).indent_right;    
                                    

            format_id := add_format(format, doc_id);
            
        END IF;
        
        format_string := NULL;
        
        IF format_id IS NOT NULL THEN
            format_string := ' s="'||format_id||'"';
        ELSIF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_id IS NOT NULL THEN 
            format_string := ' s="'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).format_id||'"'; 
        END IF;

        IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).formula IS NOT NULL THEN 
            formula := '<f>'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).formula||'</f>';
        END IF;

        IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_type = 'N' THEN 
            line_string(doc_id) := '<c r="'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_name||'"'||format_string||'>'||formula||'<v>'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_value||'</v></c>'; 
        ELSIF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_type = 'S' THEN 
            line_string(doc_id) := '<c r="'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_name||'"'||format_string||'  t="s">'||formula||'<v>'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_value||'</v></c>'; 
        ELSIF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_type = 'D' THEN 
            line_string(doc_id) := '<c r="'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_name||'"'||format_string||'>'||formula||'<v>'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_value||'</v></c>'; 
        ELSE
             line_string(doc_id) := '<c r="'||documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cell_name||'"'||format_string||'/>';    
        END IF;


        sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id)||line_string(doc_id);

        IF LENGTH(sheet_data_buffer(doc_id)) > 30000 THEN
            dbms_lob.writeappend(documents(doc_id).sheets(sheet_id).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
            sheet_data_buffer(doc_id) := NULL;
        END IF;

        
        IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).merge_cells = TRUE AND documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).merged_cells_cell_from IS NOT NULL AND documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).merges_cells_cell_to IS NOT NULL THEN 
          
            IF LENGTH(sheet_data_buffer(doc_id)) > 32000 THEN
                dbms_lob.writeappend(documents(doc_id).sheets(sheet_id).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
                sheet_data_buffer(doc_id) := NULL;
            END IF;

             FOR i IN (column_alpha2numeric(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).merged_cells_cell_from) + 1) .. column_alpha2numeric(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).merges_cells_cell_to) LOOP  
             

                IF sheet_data_buffer(doc_id) IS NOT NULL THEN
                
                   -- Update format id
                   sheet_data_buffer(doc_id) := REGEXP_REPLACE(sheet_data_buffer(doc_id), '\<c r="'||column_numeric2alpha(i)||prepare_row_id||'"(.*)s="(.*)"(.*)/>\', '<c r="'||column_numeric2alpha(i)||prepare_row_id||'"\1s="'||format_id||'"\3/>');
                   
                   -- Add format id
                   sheet_data_buffer(doc_id) := REPLACE(sheet_data_buffer(doc_id), '<c r="'||column_numeric2alpha(i)||prepare_row_id||'"/>', '<c r="'||column_numeric2alpha(i)||prepare_row_id||'" s="'||format_id||'"/>');

               ELSE

                   -- Update format id
                   documents(doc_id).sheets(sheet_id).sheet_data := REGEXP_REPLACE(documents(doc_id).sheets(sheet_id).sheet_data, '\<c r="'||column_numeric2alpha(i)||prepare_row_id||'"(.*)s="(.*)"(.*)/>\', '<c r="'||column_numeric2alpha(i)||prepare_row_id||'"\1s="'||format_id||'"\3/>');
                  
                    -- Add format id
                   documents(doc_id).sheets(sheet_id).sheet_data := REPLACE(documents(doc_id).sheets(sheet_id).sheet_data, '<c r="'||column_numeric2alpha(i)||prepare_row_id||'"/>', '<c r="'||column_numeric2alpha(i)||prepare_row_id||'" s="'||format_id||'"/>');

               END IF;
                          
            END LOOP;  
            
            IF documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cells_to_add IS NOT NULL THEN 
                sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id) || REPLACE(documents(doc_id).sheets(sheet_id).current_cell(current_cell_number).cells_to_add, 's="\2"', format_string);
            END IF;

        END IF;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100,  'Procedure prepare_cell_format'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE prepare_columns(doc_id PLS_INTEGER DEFAULT current_doc_id, sheet_id PLS_INTEGER DEFAULT current_sheet_id) IS
        cell_index PLS_INTEGER;
        row_added BOOLEAN;
    BEGIN 
      
        -- Get first index of currect_cell assoc array
        cell_index := documents(doc_id).sheets(sheet_id).current_cell.FIRST;
            
        IF cell_index IS NOT NULL THEN

            IF current_row_id < 3 THEN
                
                IF INSTR(sheet_data_buffer(doc_id), 'spans="1:1"') > 0 THEN
                    sheet_data_buffer(doc_id) := REPLACE(sheet_data_buffer(doc_id), 'spans="1:1"', 'spans="1:'||REPLACE(documents(doc_id).sheets(sheet_id).top_right_column, '0', '1')||'"');
                END IF;
                
            END IF;
            
            
            row_added := FALSE;

            -- Loop through cells
            LOOP    

                EXIT WHEN cell_index IS NULL;
                    
                IF documents(doc_id).sheets(sheet_id).current_cell(cell_index).cell_name IS NOT NULL THEN 

                    IF row_added = FALSE THEN

                        sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id)||'<row r="'||REGEXP_SUBSTR(documents(doc_id).sheets(sheet_id).current_cell(cell_index).cell_name, '[[:digit:]+].*')||'" spans="1:'||REPLACE(documents(doc_id).sheets(sheet_id).top_right_column, '0', '1')||'"'; 

                        IF documents(doc_id).sheets(sheet_id).hide_row IS NOT NULL THEN 
                            sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id)||' hidden="1"';
                            documents(doc_id).sheets(sheet_id).hide_row := NULL; 
                        END IF;     
                        
                     
                        IF documents(doc_id).sheets(sheet_id).row_height IS NOT NULL THEN 
                            sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id)||' ht="'||REPLACE(TO_CHAR(documents(doc_id).sheets(sheet_id).row_height), ',','.')||'" customHeight="1"'; 
                            documents(doc_id).sheets(sheet_id).row_height := NULL; 
                        END IF;
                        
                        sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id)||'>';
                        
                        row_added := TRUE;
                        
                    END IF;
                    
                    -- Set cell formatting  
                    prepare_cell_format(documents(doc_id).sheets(sheet_id).current_cell(cell_index).cell_name, doc_id, sheet_id);  
                    
                    -- Initialize current cell values
                    --documents(doc_id).sheets(sheet_id).current_cell(cell_index) := current_cell_record;::documents::<"@164">::current_cell::<"@93">::cell_index::<"@195">
                    
                END IF;
                -- Get next cell array index
                cell_index := documents(doc_id).sheets(sheet_id).current_cell.NEXT(cell_index);

            END LOOP;
            
            -- Delete cells formattion for current row
            documents(doc_id).sheets(sheet_id).current_cell := current_cell_empty; 

            sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id)||'</row>';
            

        END IF;
        
        
        IF LENGTH(sheet_data_buffer(doc_id)) > 32000 THEN
            dbms_lob.writeappend(documents(doc_id).sheets(sheet_id).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
            sheet_data_buffer(doc_id) := NULL;
        END IF;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure prepare_columns'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION new_document
       RETURN PLS_INTEGER
    IS
        default_font default_font_type;
        fill fills_type; 
        fill_id PLS_INTEGER;
        border borders_type;
        border_id PLS_INTEGER;
        expire_date DATE;
        format_id PLS_INTEGER;
        format formats_type; 
    BEGIN 
       
        IF doc_id < 1 THEN
          documents := documents_empty;
        END IF;

        doc_id := doc_id + 1;
        documents.EXTEND;
        current_doc_id := documents.LAST;
        current_row_id := 0;
               
        -- Initialize collectuions
        documents(current_doc_id).sheets := sheets_empty; 
        documents(current_doc_id).format_masks := format_masks_empty;
        documents(current_doc_id).formats := formats_empty;
        documents(current_doc_id).fonts := fonts_empty;
        documents(current_doc_id).fills := fills_empty;
        documents(current_doc_id).borders := borders_empty;

        -- Initialize shared strings CLOB
        documents(current_doc_id).shared_strings := EMPTY_CLOB;
        dbms_lob.createtemporary(documents(current_doc_id).shared_strings, TRUE);
        dbms_lob.open(documents(current_doc_id).shared_strings, dbms_lob.lob_readwrite);
        
        
        -- Initialize sheet data budder collection
        documents(current_doc_id).shared_strings_buffer := shared_buffer_empty;
   
        -- Initialize shared string counter, shared strings index starts at 0
        documents(current_doc_id).last_shared_string_num := - 1;
       
        -- Set default font
        default_font.font_name := 'Calibri'; 
        default_font.font_size := 11; 
        documents(current_doc_id).default_font := default_font;
                
        -- Set default fills
        fill.pattern_type := 'none';
        fill.color := NULL;
        fill_id := add_fill(fill, doc_id);
        
        fill.pattern_type := 'gray125';
        fill.color := NULL;
        fill_id := add_fill(fill, doc_id);
        
        -- Set default border
        border.border_top := FALSE;
        border.border_top_style := 'thin';
        border.border_top_color := '00000000';
        border.border_bottom := FALSE;
        border.border_bottom_style := 'thin';
        border.border_bottom_color := '00000000';
        border.border_left := FALSE;
        border.border_left_style := 'thin';
        border.border_left_color := '00000000';
        border.border_right := FALSE;
        border.border_right_style := 'thin';
        border.border_right_color := '00000000';
        border_id := add_border(border, doc_id);
        
        -- Add default number format
        format.num_fmt_id := 0;
        format.font_id := 0; 
        format.fill_id := 0; 
        format.border_id := 0; 
        format.xf_id := 0; 
        
        format_id := add_format(format, doc_id);
        
        -- Initialize shared strings buffer
        shared_strings_buffer(current_doc_id) := NULL;
        
        -- Prepare clob which will be used to initialize clobs
        DBMS_LOB.createtemporary(initialize_clob, TRUE);
        DBMS_LOB.open(initialize_clob, dbms_lob.lob_readwrite);
       
       RETURN current_doc_id;
       
    END;
    ----------------------------------------------------------------------------

    PROCEDURE new_document
    IS
    BEGIN
       -- Call overridden function
       current_doc_id := new_document;
       
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure new_document'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION add_sheet (sheet_name VARCHAR2, 
                        doc_id PLS_INTEGER DEFAULT current_doc_id)
       RETURN PLS_INTEGER
    IS
    BEGIN

        -- Add new sheet
        documents(doc_id).sheets.EXTEND;
        
        -- Get new sheet id
        current_sheet_id := documents(doc_id).sheets.LAST;
        
        -- Set sheet name
        documents(doc_id).sheets(current_sheet_id).sheet_name := translate(sheet_name, ':\/?*[]', '________'); 
        
        -- Initialize row number
        documents(doc_id).sheets(current_sheet_id).last_row_num := 0;
        
        -- Initialize CLOB which will be used to store sheet data
        documents(doc_id).sheets(current_sheet_id).sheet_data := EMPTY_CLOB;
        
        -- Create temporary file for CLOB
        dbms_lob.createtemporary(documents(doc_id).sheets(current_sheet_id).sheet_data, TRUE);
        dbms_lob.open(documents(doc_id).sheets(current_sheet_id).sheet_data, dbms_lob.lob_readwrite);
        
        -- Initialize top right column
        documents(doc_id).sheets(current_sheet_id).top_right_column := 0;
        
        -- Initialize column widths collection
        documents(doc_id).sheets(current_sheet_id).column_properites := column_properites_empty; 
        
        -- Initialize hyperlinks collection
        documents(doc_id).sheets(current_sheet_id).hyperlinks := hyperlinks_empty;
        
        -- Initialize internal hyperlinks collection
        documents(doc_id).sheets(current_sheet_id).internal_hyperlinks := internal_hyperlinks_empty;
        
        -- Initialize comments collection
        documents(doc_id).sheets(current_sheet_id).comments := comments_empty; 
        
        -- Initialize sheet data budder collection
        documents(doc_id).sheets(current_sheet_id).sheet_data_buffer := sheet_buffer_empty; 
        
        -- Initializa sheet cell info collection
        documents(doc_id).sheets(current_sheet_id).current_cell := current_cell_empty; 
        
        -- Check is initialized, initialize if it is not 
        BEGIN
            sheet_data_buffer(doc_id) := sheet_data_buffer(doc_id);
        EXCEPTION
            WHEN no_data_found THEN
                sheet_data_buffer(doc_id) := NULL;
        END;
        
        -- Check is initialized, initialize if it is not
        BEGIN
            line_string(doc_id) := line_string(doc_id);
        EXCEPTION
            WHEN no_data_found THEN
                line_string(doc_id) := NULL;
        END;
        
        -- Clean buffers
        IF sheet_data_buffer.LAST IS NULL THEN
            sheet_data_buffer(doc_id) := NULL;
        END IF;
        
        IF  line_string.LAST IS NULL THEN
            line_string(doc_id) := NULL;
        END IF;

        -- Write buffer from previous sheet
        IF current_sheet_id > 1 THEN  
        
            prepare_columns(doc_id, current_sheet_id - 1);
           
            IF LENGTH(sheet_data_buffer(doc_id)) > 0 THEN
                dbms_lob.writeappend(documents(doc_id).sheets(current_sheet_id - 1).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
                sheet_data_buffer(doc_id) := NULL;
            END IF;

        END IF;
        
        -- Clean buffers
        sheet_data_buffer(doc_id) := NULL;
        line_string(doc_id) := NULL;
        
        -- Initialize collection for merged cells
        documents(doc_id).sheets(current_sheet_id).merged_cells := merged_cells_empty; 
        
        RETURN current_sheet_id;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Function add_sheet'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_column_width(name VARCHAR2, width NUMBER, doc_id PLS_INTEGER DEFAULT current_doc_id, sheet_id PLS_INTEGER DEFAULT current_sheet_id) IS
        column_id PLS_INTEGER;
    BEGIN
        
        IF documents(doc_id).sheets(sheet_id).column_properites.LAST IS NOT NULL THEN

            FOR i IN documents(doc_id).sheets(sheet_id).column_properites.FIRST .. documents(doc_id).sheets(sheet_id).column_properites.LAST LOOP
                IF documents(doc_id).sheets(sheet_id).column_properites(i).column_name = UPPER(name) THEN 
                    column_id := i;
                    EXIT;
                END IF;       
            END LOOP;

        END IF;
        
        IF column_id IS NULL THEN
            documents(doc_id).sheets(sheet_id).column_properites.EXTEND;
            column_id := documents(doc_id).sheets(sheet_id).column_properites.LAST;
        END IF;

        documents(doc_id).sheets(sheet_id).column_properites(column_id).column_name := UPPER(name); 
        documents(doc_id).sheets(sheet_id).column_properites(column_id).width := width; 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_column_widt'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE add_sheet (
       sheet_name VARCHAR2,
       doc_id PLS_INTEGER DEFAULT current_doc_id
    )
    IS
    BEGIN
       -- Call overridden function
       current_sheet_id := add_sheet (sheet_name, doc_id);
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure add_sheet'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
       
    FUNCTION add_row(doc_id PLS_INTEGER DEFAULT current_doc_id, 
                     sheet_id PLS_INTEGER DEFAULT current_sheet_id) RETURN PLS_INTEGER
    IS
        last_buffer_id INTEGER;
        free_rows_limit INTEGER := 5 * 20;
    BEGIN 

        prepare_columns(doc_id, sheet_id);
        
        -- Increment row number
        documents(doc_id).sheets(sheet_id).last_row_num := documents(doc_id).sheets(sheet_id).last_row_num + 1;
        current_row_id := documents(doc_id).sheets(sheet_id).last_row_num;
        
        -- Set application info, so it can be visible in v$session while procedure is running
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL - Sheet '||sheet_id||' - Row '||current_row_id);

        -- Move content from cache if cache contains more than 1000000 characters
        IF DBMS_LOB.getlength(documents(doc_id).sheets(sheet_id).sheet_data) > 1000000 THEN

            documents(doc_id).sheets(sheet_id).sheet_data_buffer.EXTEND;
            last_buffer_id := documents(doc_id).sheets(sheet_id).sheet_data_buffer.LAST;
            
            dbms_lob.createtemporary(documents(doc_id).sheets(sheet_id).sheet_data_buffer(last_buffer_id), TRUE);
            dbms_lob.open(documents(doc_id).sheets(sheet_id).sheet_data_buffer(last_buffer_id), dbms_lob.lob_readwrite);
            
            DBMS_LOB.append(documents(doc_id).sheets(sheet_id).sheet_data_buffer(last_buffer_id), documents(doc_id).sheets(sheet_id).sheet_data);
            documents(doc_id).sheets(sheet_id).sheet_data := initialize_clob;  

        END IF;

        -- Initialize cell formatting flag for next cycle
        cell_formatted := FALSE;

        RETURN current_row_id;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure add_row'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE add_row(doc_id PLS_INTEGER DEFAULT current_doc_id, 
                      sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
        row_id PLS_INTEGER;
    BEGIN
        row_id := add_row(doc_id, sheet_id);
    END;
    
    
    FUNCTION add_format_mask (format_mask VARCHAR2, doc_id PLS_INTEGER) RETURN NUMBER IS
       mask_id PLS_INTEGER;
    BEGIN
        -- Check if string exists
        IF documents(doc_id).format_masks.LAST IS NOT NULL THEN
            FOR i IN documents(doc_id).format_masks.FIRST .. documents(doc_id).format_masks.LAST LOOP
                IF documents(doc_id).format_masks(i).format_mask = format_mask
                THEN
                    RETURN i + 164;
                END IF;
            END LOOP;
        END IF;

        -- If string not exists add to list
        documents(doc_id).format_masks.EXTEND;
        mask_id := documents(doc_id).format_masks.LAST;
        
        documents(doc_id).format_masks(mask_id).format_mask := format_mask;
        
        RETURN mask_id + 164;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Function add_format_mask'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_format (cell_name VARCHAR2,
                               format VARCHAR2, 
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                               row_id PLS_INTEGER DEFAULT current_row_id) IS
        
    BEGIN
        
        current_cell_number := column_alpha2numeric(cell_name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(cell_name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).format_num_fmt_id := add_format_mask(format, doc_id); 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_format'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value NUMBER, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id) 
    IS      
    BEGIN

        current_cell_number := column_alpha2numeric(name);

        -- Skeep cell tag id value is null
        IF value IS NOT NULL THEN        

            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_type := 'N'; -- Number 
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_value := REPLACE(TO_CHAR(value), ',', '.');
            
        END IF;    

        -- Remember top right column number
        IF column_alpha2numeric(name) > documents(doc_id).sheets(sheet_id).top_right_column THEN
            documents(doc_id).sheets(sheet_id).top_right_column := column_alpha2numeric(name);
        END IF;   
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_value number -'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value VARCHAR2, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id) 
    IS 
      
        last_buffer_id INTEGER;
        
    BEGIN

        current_cell_number := column_alpha2numeric(name);

        IF DBMS_LOB.getlength(documents(doc_id).shared_strings) > 1000000 THEN

            documents(doc_id).shared_strings_buffer.EXTEND;
            last_buffer_id := documents(doc_id).shared_strings_buffer.LAST;
            
            dbms_lob.createtemporary(documents(doc_id).shared_strings_buffer(last_buffer_id), TRUE);
            dbms_lob.open(documents(doc_id).shared_strings_buffer(last_buffer_id), dbms_lob.lob_readwrite);
            
            DBMS_LOB.append(documents(doc_id).shared_strings_buffer(last_buffer_id), documents(doc_id).shared_strings);
            documents(doc_id).shared_strings := initialize_clob;

        END IF;

        -- Skeep cell tag id value is null
        IF value IS NOT NULL THEN
            
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_type := 'S'; -- String 
            
            -- Increment shared strings counter
            documents(doc_id).last_shared_string_num := documents(doc_id).last_shared_string_num + 1;

            line_string(doc_id) := '<si><t>'||REPLACE(dbms_xmlgen.convert(REGEXP_REPLACE(REPLACE(value, CHR(10), '__NEW_LINE__'),'[[:cntrl:]]','')), '__NEW_LINE__', CHR(10))||'</t></si>';
            IF (LENGTH(shared_strings_buffer(doc_id)) + LENGTH(line_string(doc_id))) >= 25000 THEN

                dbms_lob.writeappend(documents(doc_id).shared_strings, LENGTH(shared_strings_buffer(doc_id)), shared_strings_buffer(doc_id));
                shared_strings_buffer(doc_id) := line_string(doc_id);
                
            ELSE

                shared_strings_buffer(doc_id) := shared_strings_buffer(doc_id) || line_string(doc_id);
                
            END IF;
            
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_value := documents(doc_id).last_shared_string_num; -- String
                            
        END IF;
        
        -- Remember top right column number
        IF column_alpha2numeric(name) > documents(doc_id).sheets(sheet_id).top_right_column THEN
            documents(doc_id).sheets(sheet_id).top_right_column := column_alpha2numeric(name);
        END IF;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_value varchar2'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value CLOB, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id) 
    IS    
        
        last_buffer_id INTEGER;
        
    BEGIN

        current_cell_number := column_alpha2numeric(name);

        IF DBMS_LOB.getlength(documents(doc_id).shared_strings) > 1000000 THEN

            documents(doc_id).shared_strings_buffer.EXTEND;
            last_buffer_id := documents(doc_id).shared_strings_buffer.LAST;
            
            dbms_lob.createtemporary(documents(doc_id).shared_strings_buffer(last_buffer_id), TRUE);
            dbms_lob.open(documents(doc_id).shared_strings_buffer(last_buffer_id), dbms_lob.lob_readwrite);
            
            DBMS_LOB.append(documents(doc_id).shared_strings_buffer(last_buffer_id), documents(doc_id).shared_strings);
            documents(doc_id).shared_strings := initialize_clob;

        END IF;

        -- Skeep cell tag id value is null
        IF value IS NOT NULL THEN

            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_type := 'S'; -- String 
            
            
            -- Increment shared strings counter
            documents(doc_id).last_shared_string_num := documents(doc_id).last_shared_string_num + 1;
            
            -- Add value to shared strings CLOB
            append_to_clob(documents(doc_id).shared_strings, '<si><t>');
            dbms_lob.append(documents(doc_id).shared_strings, value);
            append_to_clob(documents(doc_id).shared_strings, '</t></si>');
            
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_value := documents(doc_id).last_shared_string_num; 
                                       
        END IF;         
        
        -- Remember top right column number
        IF column_alpha2numeric(name) > documents(doc_id).sheets(sheet_id).top_right_column THEN
            documents(doc_id).sheets(sheet_id).top_right_column := column_alpha2numeric(name);
        END IF;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_value clob'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_value (name VARCHAR2, 
                              value DATE, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    
        format formats_type; 
        cell_format_id INTEGER; 
        
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        -- Skeep cell tag id value is null
        IF value IS NOT NULL THEN

            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_type := 'D'; -- Date 
            
            -- Prepare format mask
            IF value != TRUNC(value) THEN
                format.num_fmt_id := 22;
                format.font_id := 0; 
                format.fill_id := 0; 
                format.border_id := 0; 
                format.xf_id := 0; 
                cell_format_id := add_format(format, doc_id);
            ELSE
                format.num_fmt_id := 14;
                format.font_id := 0; 
                format.fill_id := 0; 
                format.border_id := 0; 
                format.xf_id := 0; 
                cell_format_id := add_format(format, doc_id);
            END IF;
            
            IF NVL(date_system, 1904) = 1904 THEN
                documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_value := REPLACE(TO_CHAR(ROUND(value - TO_DATE('01.01.1904','dd.mm.yyyy'), 12) + 1), ',', '.'); 
            ELSE
                documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_value := REPLACE(TO_CHAR(ROUND(value - TO_DATE('01.01.1900','dd.mm.yyyy'), 12) + 2), ',', '.'); 
            END IF;
            documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).format_id := cell_format_id; 
                       
        END IF;                                        
        
         -- Remember top right column number
        IF column_alpha2numeric(name) > documents(doc_id).sheets(sheet_id).top_right_column THEN
            documents(doc_id).sheets(sheet_id).top_right_column := column_alpha2numeric(name);
        END IF; 
        
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_value date'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION little_endian (in_big NUMBER, 
                            in_bytes PLS_INTEGER := 4) RETURN RAW 
    IS
    BEGIN
        RETURN UTL_RAW.substr (
            UTL_RAW.cast_from_binary_integer (in_big, UTL_RAW.little_endian),
            1,
            in_bytes
        );
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Function little_endian'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
        
    PROCEDURE add_file(compressed_blob in out nocopy blob, 
                       name varchar2, 
                       content blob)
    IS
        t_now DATE;
        t_blob BLOB;
        t_clen INTEGER; 
    BEGIN
        t_now := SYSDATE;
        t_blob := utl_compress.lz_compress(content);
        t_clen := dbms_lob.getlength( t_blob );
        
    IF compressed_blob IS NULL THEN
      dbms_lob.createtemporary(compressed_blob, TRUE);
    END IF;

        dbms_lob.append(compressed_blob, 
                          utl_raw.CONCAT(HEXTORAW('504B0304'), 
                                         HEXTORAW('1400'), 
                                         HEXTORAW('0000'),
                                         HEXTORAW('0800'),
                                         little_endian( TO_NUMBER(TO_CHAR(t_now, 'ss')) / 2
                                                      + TO_NUMBER(TO_CHAR(t_now, 'mi')) * 32
                                                      + TO_NUMBER(TO_CHAR(t_now, 'hh24')) * 2048
                                                      , 2
                                                      ), 
                                         little_endian( TO_NUMBER(TO_CHAR( t_now, 'dd'))
                                                      + TO_NUMBER(TO_CHAR( t_now, 'mm')) * 32
                                                      + (TO_NUMBER(TO_CHAR( t_now, 'yyyy' )) - 1980) * 512
                                                      , 2) 
                                       , dbms_lob.substr(t_blob, 4, t_clen - 7)
                                       , little_endian( t_clen - 18 )
                                       , little_endian( dbms_lob.getlength(content)) 
                                       , little_endian( length(name), 2)             
                                       , HEXTORAW('0000')                              
                                       , utl_raw.cast_to_raw(name)                    
                                       )
                       );
        dbms_lob.copy(compressed_blob, t_blob, t_clen - 18, dbms_lob.getlength( compressed_blob ) + 1, 11);
        dbms_lob.freetemporary(t_blob);
    
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure add_file'||SQLCODE||' '||SQLERRM);
    END;
    ------------------------------------------------------------------------------
  
    PROCEDURE add_xml (document_blob IN OUT NOCOPY BLOB, 
                       file_name VARCHAR2, 
                       xml_clob CLOB) IS
       tmp_blob   BLOB := EMPTY_BLOB();
       tmp_raw RAW(5000);
    BEGIN
       DBMS_LOB.createtemporary (tmp_blob, TRUE);

       FOR i IN 0 .. TRUNC (LENGTH (xml_clob) / 2000)
       LOOP
          tmp_raw := UTL_I18N.string_to_raw (SUBSTR (xml_clob, i * 2000 + 1, 2000), 'AL32UTF8');
          IF tmp_raw IS NOT NULL THEN
            DBMS_LOB.append (tmp_blob, tmp_raw);
          END IF;
       END LOOP;

       add_file (document_blob, file_name, tmp_blob);
       DBMS_LOB.freetemporary (tmp_blob);
    
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure add_xml'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------

    PROCEDURE compress_document (compressed_blob IN OUT NOCOPY BLOB)
    IS
       t_cnt               PLS_INTEGER := 0;
       t_offs              INTEGER;
       t_offs_dir_header   INTEGER;
       t_offs_end_header   INTEGER;
       t_comment RAW (32767) := UTL_RAW.cast_to_raw (' ');
    BEGIN
       t_offs_dir_header := DBMS_LOB.getlength (compressed_blob);
       t_offs := DBMS_LOB.INSTR (compressed_blob, HEXTORAW ('504B0304'), 1);

       WHILE t_offs > 0
       LOOP
          t_cnt := t_cnt + 1;
          DBMS_LOB.append (
             compressed_blob,
             UTL_RAW.CONCAT (
                HEXTORAW ('504B0102'),
                HEXTORAW ('1400'), 
                DBMS_LOB.SUBSTR (compressed_blob, 26, t_offs + 4), HEXTORAW ('0000'),
                HEXTORAW ('0000'), 
                HEXTORAW ('0100'), 
                HEXTORAW ('2000B681'),
                little_endian (t_offs - 1),
                DBMS_LOB.SUBSTR (
                   compressed_blob,
                   UTL_RAW.cast_to_binary_integer (
                      DBMS_LOB.SUBSTR (compressed_blob, 2, t_offs + 26),
                      UTL_RAW.little_endian),
                   t_offs + 30)
                )
          );
          t_offs := DBMS_LOB.INSTR (compressed_blob, HEXTORAW ('504B0304'), t_offs + 32);
       END LOOP;

       t_offs_end_header := DBMS_LOB.getlength (compressed_blob);
       DBMS_LOB.append (
          compressed_blob,
          UTL_RAW.CONCAT (
             HEXTORAW ('504B0506'), 
             HEXTORAW ('0000'), 
             HEXTORAW ('0000'), 
             little_endian (t_cnt, 2),
             little_endian (t_cnt, 2),
             little_endian (t_offs_end_header - t_offs_dir_header),
             little_endian (t_offs_dir_header),
             little_endian (NVL (UTL_RAW.LENGTH (t_comment), 0), 2),
             t_comment));
             
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure compress_document'||SQLCODE||' '||SQLERRM);
    END;
    ------------------------------------------------------------------------------
        
    PROCEDURE blob2file (p_blob BLOB, 
                         p_directory VARCHAR2, 
                         p_filename VARCHAR2)
    IS
       t_fh    UTL_FILE.file_type;
       t_len   PLS_INTEGER := 32767;
    BEGIN
       t_fh := UTL_FILE.fopen (p_directory, p_filename, 'wb');

       FOR i IN 0 .. TRUNC ( (DBMS_LOB.getlength (p_blob) - 1) / t_len)
       LOOP
          UTL_FILE.put_raw (t_fh, DBMS_LOB.SUBSTR (p_blob, t_len, i * t_len + 1));
       END LOOP;

       UTL_FILE.fclose (t_fh);
       
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure blob2file'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE save_to_blob(blob_file IN OUT BLOB, 
                           doc_id PLS_INTEGER DEFAULT current_doc_id) IS
        file_content CLOB;
        file_content2 CLOB := EMPTY_CLOB;
        last_row PLS_INTEGER;
        top_right_column PLS_INTEGER;
        first_sheet PLS_INTEGER;
        last_sheet PLS_INTEGER;
        last_i PLS_INTEGER;
        show_header BOOLEAN;
        rel_id PLS_INTEGER;
        drawing_added BOOLEAN;
    BEGIN

        -- Write content from buffer of last sheet to clob of that sheet
        IF sheet_data_buffer(doc_id) IS NOT NULL THEN
            dbms_lob.writeappend(documents(doc_id).sheets(current_sheet_id).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
            sheet_data_buffer(doc_id) := NULL;
        END IF;
       

        prepare_columns(doc_id, current_sheet_id);
      
        -- Delete cells formattion for current row
        documents(doc_id).sheets(current_sheet_id).current_cell := current_cell_empty; 

        -- Write cell cata to CLOB
        IF sheet_data_buffer(doc_id) IS NOT NULL THEN
            dbms_lob.writeappend(documents(doc_id).sheets(current_sheet_id).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
            sheet_data_buffer(doc_id) := NULL;
        END IF;

        -- Prepare temporary CLOB
        dbms_lob.createtemporary(blob_file, TRUE);
        dbms_lob.createtemporary(file_content2, TRUE);
        dbms_lob.open(file_content2, dbms_lob.lob_readwrite);
        
        first_sheet := documents(doc_id).sheets.FIRST;
        last_sheet := documents(doc_id).sheets.LAST;


        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 1/12');
        -- [Content_Types].xml
        line_string(doc_id) := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10)
                    || '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                    || '<Override PartName="/xl/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>'
                    || '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
                    || '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                    || '<Default Extension="xml" ContentType="application/xml"/>'
                    || '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
                    || '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
                    || '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>';

        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
        line_string(doc_id) := NULL;
        
        IF last_sheet IS NOT NULL THEN
            FOR i IN first_sheet .. last_sheet LOOP
                line_string(doc_id) := line_string(doc_id) || '<Override PartName="/xl/worksheets/sheet'||i||'.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>';
                IF LENGTH(line_string(doc_id)) > 30000 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
            END LOOP;
        END IF;
        
        IF documents(doc_id).shared_strings IS NOT NULL THEN
            line_string(doc_id) := line_string(doc_id) || '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>';
        END IF;
        
        drawing_added := FALSE;
        IF last_sheet IS NOT NULL THEN

            FOR i IN first_sheet .. last_sheet LOOP

                IF documents(doc_id).sheets(i).comments.LAST IS NOT NULL THEN

                   line_string(doc_id) := line_string(doc_id) || '<Override ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml" PartName="/xl/comments'||i||'.xml"/>';

                    IF drawing_added = FALSE THEN
                        line_string(doc_id) := line_string(doc_id) || '<Default ContentType="application/vnd.openxmlformats-officedocument.vmlDrawing" Extension="vml"/>';
                        drawing_added := TRUE;
                    END IF;
                   
                END IF;
                
            END LOOP;
            
        END IF;
        
        line_string(doc_id) := line_string(doc_id) || '</Types>';
        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));

        add_xml(blob_file, '[Content_Types].xml', file_content2);
        
        dbms_lob.close(file_content2);
        
        print_clob(file_content2, '[Content_Types].xml');
        ------------------------------------------------------------------------
        
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 2/12');
        -- _rels/.rels
        file_content := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10)
                     || '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                     || '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
                     || '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
                     || '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
                     || '</Relationships>';
        add_xml(blob_file, '_rels/.rels', file_content);
        ------------------------------------------------------------------------
        print_clob(file_content, '_rels/.rels');
        
        
        -- xl/worksheets/_rels/sheetN.xml.rels
        IF documents(doc_id).sheets.LAST IS NOT NULL THEN
                  
            FOR i IN documents(doc_id).sheets.FIRST .. documents(doc_id).sheets.LAST LOOP

                IF documents(doc_id).sheets(i).hyperlinks.LAST IS NOT NULL OR
                   documents(doc_id).sheets(i).comments.LAST IS NOT NULL
                THEN
                    file_content := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10)
                                 || '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';
                    rel_id := 0;
                END IF;
                
                IF documents(doc_id).sheets(i).comments.LAST IS NOT NULL THEN

                   rel_id := rel_id + 1;
                   file_content := file_content ||'<Relationship Id="rId'||rel_id||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing" Target="../drawings/vmlDrawing'||i||'.vml"/>';
                        
                   rel_id := rel_id + 1;
                   file_content := file_content ||'<Relationship Id="rId'||rel_id||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments" Target="../comments'||i||'.xml"/>';

                END IF;
                   

                IF documents(doc_id).sheets(i).hyperlinks.LAST IS NOT NULL THEN
                         
                    FOR j IN documents(doc_id).sheets(i).hyperlinks.FIRST .. documents(doc_id).sheets(i).hyperlinks.LAST LOOP
                       rel_id := rel_id + 1;
                       file_content := file_content ||'<Relationship Id="rId'||rel_id||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="'||documents(doc_id).sheets(i).hyperlinks(j).hyperlink||'" TargetMode="External"/>'; 

                    END LOOP;

                END IF;                                
                
                
                IF documents(doc_id).sheets(i).hyperlinks.LAST IS NOT NULL OR
                   documents(doc_id).sheets(i).comments.LAST IS NOT NULL
                THEN
                    file_content := file_content ||'</Relationships>';
                    
                    add_xml(blob_file, 'xl/worksheets/_rels/sheet'||i||'.xml.rels', file_content);
                    ------------------------------------------------------------------------
                    print_clob(file_content, 'xl/worksheets/_rels/sheet'||i||'.xml.rels');
                    
                END IF;

            END LOOP;

        END IF;
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 3/12');
        -- xl\commentsN.xml
        IF documents(doc_id).sheets.LAST IS NOT NULL THEN
                  
            FOR i IN documents(doc_id).sheets.FIRST .. documents(doc_id).sheets.LAST LOOP

                IF documents(doc_id).sheets(i).comments.LAST IS NOT NULL THEN

                    file_content := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>    '||CHR(10)
                                 || '<comments xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><authors><author>'||dbms_xmlgen.convert(NVL(documents(doc_id).author, 'ORA_EXCEL'))||'</author></authors><commentList>';
                         
                    FOR j IN documents(doc_id).sheets(i).comments.FIRST .. documents(doc_id).sheets(i).comments.LAST LOOP
                                    
                        file_content := file_content ||'<comment ref="'||documents(doc_id).sheets(i).comments(j).cell||'" authorId="0"><text>'; 
                                              
                        file_content := file_content ||'<r><rPr><b/><sz val="9"/><color indexed="81"/><rFont val="Tahoma"/><family val="2"/></rPr><t>'||NVL(dbms_xmlgen.convert(documents(doc_id).sheets(i).comments(j).author), 'Comment:')||'</t></r><r>'; 
                                               
                        file_content := file_content ||'<rPr><sz val="9"/><color indexed="81"/><rFont val="Tahoma"/><family val="2"/></rPr><t xml:space="preserve">'||CHR(10)||dbms_xmlgen.convert(documents(doc_id).sheets(i).comments(j).comment_text)||'</t></r></text></comment>'; 

                    END LOOP;
                    
                    file_content := file_content ||'</commentList></comments>';
                    
                    add_xml(blob_file, 'xl/comments'||i||'.xml', file_content);
                    ------------------------------------------------------------------------
                    print_clob(file_content, 'xl/comments'||i||'.xml');
                    
                END IF;

            END LOOP;

        END IF; 
        
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 4/12');
        -- xl\drawings\vmlDrawingN.vml
        IF documents(doc_id).sheets.LAST IS NOT NULL THEN
                  
            FOR i IN documents(doc_id).sheets.FIRST .. documents(doc_id).sheets.LAST LOOP
     
                IF documents(doc_id).sheets(i).comments.LAST IS NOT NULL THEN
                    
                    dbms_lob.createtemporary(file_content2, TRUE);
                    dbms_lob.open(file_content2, dbms_lob.lob_readwrite);

                    file_content := '<xml xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">'||CHR(10)
                                 || '<o:shapelayout v:ext="edit"><o:idmap v:ext="edit" data="1"/></o:shapelayout><v:shapetype id="_x0000_t202" coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/></v:shapetype>';                                
                         
                    FOR j IN documents(doc_id).sheets(i).comments.FIRST .. documents(doc_id).sheets(i).comments.LAST LOOP
                                    
                        file_content := file_content ||'<v:shape id="_x0000_s'||(1025 + j)||'" type="#_x0000_t202" style=''position:absolute;margin-left:57pt;margin-top:1.2pt;width:'||NVL(documents(doc_id).sheets(i).comments(j).box_width, 100)||'pt;height:'||NVL(documents(doc_id).sheets(i).comments(j).box_height, 60)|| 
                                                       'pt;z-index:1;visibility:hidden'' fillcolor="#ffffe1" o:insetmode="auto"><v:fill color2="#ffffe1"/><v:shadow on="t" color="black" obscured="t"/><v:path o:connecttype="none"/><v:textbox style=''mso-direction-alt:auto''>';
                        file_content := file_content ||'<div style=''text-align:left''></div></v:textbox><x:ClientData ObjectType="Note"><x:MoveWithCells/><x:SizeWithCells/><x:Anchor>1, 15, 0, 2, '||ROUND(NVL(documents(doc_id).sheets(i).comments(j).box_width, 60) / 40)||', 31, '||ROUND(NVL(documents(doc_id).sheets(i).comments(j).box_height, 60) / 15)||', 1</x:Anchor><x:AutoFill>False</x:AutoFill>'; 
                        file_content := file_content ||'<x:Row>'||(documents(doc_id).sheets(i).comments(j).row_id)||'</x:Row><x:Column>'||(documents(doc_id).sheets(i).comments(j).column_id)||'</x:Column></x:ClientData></v:shape>'; 
                        
                        IF LENGTH(file_content) > 28000 THEN 
                            dbms_lob.writeappend(file_content2, LENGTH(file_content), file_content);
                            file_content := NULL;
                        END IF;
                        
                    END LOOP;
                    
                    file_content := file_content ||'</xml>';
                    dbms_lob.writeappend(file_content2, LENGTH(file_content), file_content);
                                        
                    add_xml(blob_file, 'xl\drawings\vmlDrawing'||i||'.vml', file_content2);
                    ------------------------------------------------------------------------
                    print_clob(file_content2, 'xl\drawings\vmlDrawing'||i||'.vml');
                    dbms_lob.close(file_content2);
                    
                END IF;

            END LOOP;

        END IF;
             
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 5/12');
        -- xl/_rels/workbook.xml.rels
        dbms_lob.createtemporary(file_content2, TRUE);
        dbms_lob.open(file_content2, dbms_lob.lob_readwrite);
        
        file_content :=                 '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10);
        file_content := file_content || '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';

        IF last_sheet IS NOT NULL THEN
            FOR i IN first_sheet .. last_sheet LOOP
                file_content := file_content || '<Relationship Id="rId'||i||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet'||i||'.xml"/>';
                last_i := i;
                IF LENGTH(file_content) > 10000 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(file_content), file_content);
                    file_content := NULL;
                END IF;
            END LOOP;
        END IF;
 
        IF documents(doc_id).shared_strings IS NOT NULL THEN
            file_content := file_content || '<Relationship Id="rId'||(last_sheet + 3)||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>';
        END IF;

        file_content := file_content || '<Relationship Id="rId'||(last_sheet + 2)||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
                                     || '<Relationship Id="rId'||(last_sheet + 1)||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>'
                                     || '</Relationships>';
                                      
        dbms_lob.writeappend(file_content2, LENGTH(file_content), file_content);
        add_xml(blob_file, 'xl/_rels/workbook.xml.rels', file_content2);
        dbms_lob.close(file_content2);
        ------------------------------------------------------------------------
        print_clob(file_content, 'xl/_rels/workbook.xml.rels');
        
         
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 6/12');
        -- xl/workbook.xml
        dbms_lob.createtemporary(file_content2, TRUE);
        dbms_lob.open(file_content2, dbms_lob.lob_readwrite);
        file_content :=    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10)
                        || '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
                        || '<fileVersion appName="xl" lastEdited="4" lowestEdited="4" rupBuild="4505"/>'
                        || '<workbookPr ';
        IF NVL(date_system, 1904) = 1904 THEN
            file_content := file_content || 'date1904="true"';
        END IF;
            
         file_content := file_content || ' defaultThemeVersion="124226"/>'
                                      || '<bookViews>'
                                      || '<workbookView xWindow="120" yWindow="120" windowWidth="28695" windowHeight="14310"/>'
                                      || '</bookViews>'
                                      || '<sheets>';
        IF last_sheet IS NOT NULL THEN
            FOR i IN first_sheet .. last_sheet LOOP
                file_content := file_content || '<sheet name="'||dbms_xmlgen.convert(documents(doc_id).sheets(i).sheet_name)||'" sheetId="'||i||'" r:id="rId'||i||'"/>';
                IF LENGTH(file_content) > 10000 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(file_content), file_content);
                    file_content := NULL;
                END IF; 
            END LOOP;
        END IF;
        file_content := file_content || '</sheets>'
                                     || '<calcPr calcId="124519"/>'
                                     || '</workbook>';
         dbms_lob.writeappend(file_content2, LENGTH(file_content), file_content);
        add_xml(blob_file, 'xl/workbook.xml', file_content2);
        dbms_lob.close(file_content2);
        ------------------------------------------------------------------------  
        print_clob(file_content, 'xl/workbook.xml');
        
        
        
        
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 7/12');
        -- xl/styles.xml
        dbms_lob.createtemporary(file_content2, TRUE);
        dbms_lob.open(file_content2, dbms_lob.lob_readwrite);
        
        line_string(doc_id) :=  '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10)||'<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">';
        
        -- Formats
        IF documents(doc_id).format_masks.LAST IS NOT NULL THEN

            line_string(doc_id) := line_string(doc_id) || '<numFmts count="'||NVL(documents(doc_id).format_masks.LAST, 0)||'">';
            
            FOR i IN documents(doc_id).format_masks.FIRST .. documents(doc_id).format_masks.LAST LOOP
             
                line_string(doc_id) := line_string(doc_id) || '<numFmt numFmtId="'||(i + 164)||'" formatCode="'||documents(doc_id).format_masks(i).format_mask||'"/>';
                
                IF LENGTH(line_string(doc_id)) > 3500 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
            END LOOP;

            line_string(doc_id) := line_string(doc_id) || '</numFmts>';
            
            dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
            
            line_string(doc_id) := NULL;
            
        END IF;
        
        -- Fonts
        line_string(doc_id) :=  line_string(doc_id) || '<fonts count="'||NVL(documents(doc_id).fonts.LAST, 1)||'">';
        
        -- Default font
        line_string(doc_id) := line_string(doc_id) || '<font>';
        line_string(doc_id) := line_string(doc_id) || '<sz val="'||documents(doc_id).default_font.font_size||'"/>'; 
        line_string(doc_id) := line_string(doc_id) || '<name val="'||documents(doc_id).default_font.font_name||'"/>'; 
        line_string(doc_id) := line_string(doc_id) || '</font>';
        
        
        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
        
        line_string(doc_id) := NULL;
        
        IF documents(doc_id).fonts.LAST IS NOT NULL THEN
            FOR i IN documents(doc_id).fonts.FIRST .. documents(doc_id).fonts.LAST LOOP

                line_string(doc_id) := line_string(doc_id) || '<font>';
                
                IF documents(doc_id).fonts(i).bold = TRUE THEN 
                    line_string(doc_id) := line_string(doc_id) || '<b/>';
                END IF;
                
                IF documents(doc_id).fonts(i).italic = TRUE THEN 
                    line_string(doc_id) := line_string(doc_id) || '<i/>';
                END IF;
                
                IF documents(doc_id).fonts(i).underline = TRUE THEN 
                    line_string(doc_id) := line_string(doc_id) || '<u/>';
                END IF;
                
                IF documents(doc_id).fonts(i).color IS NOT NULL THEN 
                    line_string(doc_id) := line_string(doc_id) || '<color rgb="'||documents(doc_id).fonts(i).color||'"/>'; 
                END IF;
                
                line_string(doc_id) := line_string(doc_id) || '<sz val="'||documents(doc_id).fonts(i).font_size||'"/>'; 
                
                line_string(doc_id) := line_string(doc_id) || '<name val="'||dbms_xmlgen.convert(documents(doc_id).fonts(i).font_name)||'"/>'; 
                
                line_string(doc_id) := line_string(doc_id) || '</font>';
                IF LENGTH(line_string(doc_id)) > 3500 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
                
            END LOOP; 
        END IF;
        
        line_string(doc_id) := line_string(doc_id) || '</fonts>';
        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));

        -- Fills
        line_string(doc_id) := '<fills count="'||NVL(documents(doc_id).fills.LAST, 0)||'">';
        
        IF documents(doc_id).fills.LAST IS NOT NULL THEN
                   
            FOR i IN documents(doc_id).fills.FIRST .. documents(doc_id).fills.LAST LOOP
                            
                line_string(doc_id) := line_string(doc_id) || '<fill>';

                line_string(doc_id) := line_string(doc_id) || '<patternFill patternType="'||documents(doc_id).fills(i).pattern_type||'"';
                
                IF documents(doc_id).fills(i).color IS NOT NULL THEN
                    line_string(doc_id) := line_string(doc_id) || '><fgColor  rgb="'||documents(doc_id).fills(i).color||'"/><bgColor indexed="64"/></patternFill>';
                ELSE
                    line_string(doc_id) := line_string(doc_id) || '/>';
                END IF;
                    
                line_string(doc_id) := line_string(doc_id) || '</fill>';
                
                IF LENGTH(line_string(doc_id)) > 3500 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
                       
            END LOOP;
                
        END IF;
        
        line_string(doc_id) := line_string(doc_id) || '</fills>';
        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
        
        line_string(doc_id) := '<borders count="'||NVL(documents(doc_id).borders.LAST, 0)||'">';
        
        IF documents(doc_id).borders.LAST IS NOT NULL THEN
                   
            FOR i IN documents(doc_id).borders.FIRST .. documents(doc_id).borders.LAST LOOP
                            
                line_string(doc_id) := line_string(doc_id) || '<border>';
                
                IF documents(doc_id).borders(i).border_left = TRUE THEN
                    line_string(doc_id) := line_string(doc_id) ||'<left style="'||NVL(documents(doc_id).borders(i).border_left_style, 'thin')||'"><color rgb="'||NVL(documents(doc_id).borders(i).border_left_color, '00000000')||'"/></left>';
                ELSE
                    line_string(doc_id) := line_string(doc_id) ||'<left/>';
                END IF;
                
                IF documents(doc_id).borders(i).border_right = TRUE THEN
                    line_string(doc_id) := line_string(doc_id) ||'<right style="'||NVL(documents(doc_id).borders(i).border_right_style, 'thin')||'"><color rgb="'||NVL(documents(doc_id).borders(i).border_right_color, '00000000')||'"/></right>';
                ELSE
                    line_string(doc_id) := line_string(doc_id) ||'<right/>';
                END IF;

                IF documents(doc_id).borders(i).border_top = TRUE THEN
                    line_string(doc_id) := line_string(doc_id) ||'<top style="'||NVL(documents(doc_id).borders(i).border_top_style, 'thin')||'"><color rgb="'||NVL(documents(doc_id).borders(i).border_top_color, '00000000')||'"/></top>';
                ELSE
                    line_string(doc_id) := line_string(doc_id) ||'<top/>';
                END IF;
                
                IF documents(doc_id).borders(i).border_bottom = TRUE THEN
                    line_string(doc_id) := line_string(doc_id) ||'<bottom style="'||NVL(documents(doc_id).borders(i).border_bottom_style, 'thin')||'"><color rgb="'||NVL(documents(doc_id).borders(i).border_bottom_color, '00000000')||'"/></bottom>';
                ELSE
                    line_string(doc_id) := line_string(doc_id) ||'<bottom/>';
                END IF;
                
                line_string(doc_id) := line_string(doc_id) || '<diagonal/>';

                line_string(doc_id) := line_string(doc_id) || '</border>';
                
                IF LENGTH(line_string(doc_id)) > 3500 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
                       
            END LOOP;
                
        END IF;

        
        line_string(doc_id) := line_string(doc_id) ||'</borders>';
        line_string(doc_id) := line_string(doc_id) ||'<cellStyleXfs count="1">';
        line_string(doc_id) := line_string(doc_id) ||'<xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>';
        line_string(doc_id) := line_string(doc_id) ||'</cellStyleXfs>';
        line_string(doc_id) := line_string(doc_id) ||'<cellXfs count="'||(NVL(documents(doc_id).formats.LAST, 0) + 0)||'">';
        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
        line_string(doc_id) := NULL;
         
        IF documents(doc_id).formats.LAST IS NOT NULL THEN
            FOR i IN documents(doc_id).formats.FIRST .. documents(doc_id).formats.LAST LOOP

                line_string(doc_id) := line_string(doc_id) ||'<xf numFmtId="'||documents(doc_id).formats(i).num_fmt_id||'" fontId="'||documents(doc_id).formats(i).font_id||'" fillId="'||documents(doc_id).formats(i).fill_id||'" borderId="'||documents(doc_id).formats(i).border_id||'" xfId="'||documents(doc_id).formats(i).xf_id||'"';
               
                IF documents(doc_id).formats(i).num_fmt_id > 0 THEN
                    line_string(doc_id) := line_string(doc_id) || ' applyNumberFormat="1"';
                END IF; 
                
                IF documents(doc_id).formats(i).font_id > 0 THEN 
                    line_string(doc_id) := line_string(doc_id) || ' applyFont="1"';
                END IF; 
                
                IF documents(doc_id).formats(i).fill_id > 0 THEN 
                    line_string(doc_id) := line_string(doc_id) || ' applyFill="1"';
                END IF; 
                
                IF documents(doc_id).formats(i).border_id > 0 THEN 
                    line_string(doc_id) := line_string(doc_id) || ' applyBorder="1"';
                END IF;
                
                IF documents(doc_id).formats(i).horizontal_align IS NOT NULL OR 
                   documents(doc_id).formats(i).vertical_align IS NOT NULL OR 
                   documents(doc_id).formats(i).indent_left IS NOT NULL OR 
                   documents(doc_id).formats(i).indent_right IS NOT NULL 
                THEN
                    line_string(doc_id) := line_string(doc_id) || ' applyAlignment="1"';
                END IF;
                
                
                IF documents(doc_id).formats(i).horizontal_align IS NOT NULL OR 
                   documents(doc_id).formats(i).vertical_align IS NOT NULL OR 
                   NVL(documents(doc_id).formats(i).wrap_text, FALSE) = TRUE OR 
                   NVL(documents(doc_id).formats(i).rotate_text_degree, 0) != 0 OR 
                   NVL(documents(doc_id).formats(i).indent_left, 0) != 0 OR 
                   NVL(documents(doc_id).formats(i).indent_right, 0) != 0 
                THEN

                    line_string(doc_id) := line_string(doc_id) || '><alignment';
                    
                    IF documents(doc_id).formats(i).horizontal_align IS NOT NULL THEN 
                        CASE documents(doc_id).formats(i).horizontal_align 
                            WHEN 'L' THEN
                                line_string(doc_id) := line_string(doc_id) || ' horizontal="left"';
                            WHEN 'C' THEN
                                line_string(doc_id) := line_string(doc_id) || ' horizontal="center"';
                            WHEN 'R' THEN
                                line_string(doc_id) := line_string(doc_id) || ' horizontal="right"';
                            ELSE
                                line_string(doc_id) := line_string(doc_id) || ' horizontal="right"';
                        END CASE;    
                    END IF;
                    
                    IF documents(doc_id).formats(i).vertical_align IS NOT NULL THEN 
                        CASE documents(doc_id).formats(i).vertical_align 
                            WHEN 'T' THEN
                                line_string(doc_id) := line_string(doc_id) || ' vertical="top"';
                            WHEN 'M' THEN
                                line_string(doc_id) := line_string(doc_id) || ' vertical="center"';
                            WHEN 'B' THEN
                                line_string(doc_id) := line_string(doc_id) || ' vertical="bottom"';
                            ELSE
                                line_string(doc_id) := line_string(doc_id) || ' vertical="bottom"';
                        END CASE;    
                    END IF;
                    
                    IF NVL(documents(doc_id).formats(i).wrap_text, FALSE) = TRUE THEN 
                        line_string(doc_id) := line_string(doc_id) || ' wrapText="1"';
                    END IF;
                    
                    IF NVL(documents(doc_id).formats(i).rotate_text_degree, 0) != 0  THEN 
                         line_string(doc_id) := line_string(doc_id) || ' textRotation="'||documents(doc_id).formats(i).rotate_text_degree||'"'; 
                    END IF;
                    
                    IF NVL(documents(doc_id).formats(i).indent_left, 0) > 0  THEN 
                         IF documents(doc_id).formats(i).horizontal_align NOT IN ('L','C','R') THEN
                            line_string(doc_id) := line_string(doc_id) || ' horizontal="left" ';
                         END IF;
                         line_string(doc_id) := line_string(doc_id) || ' indent="'||documents(doc_id).formats(i).indent_left||'"'; 
                    END IF;
                    
                    IF NVL(documents(doc_id).formats(i).indent_right, 0) > 0  THEN 
                        IF documents(doc_id).formats(i).horizontal_align NOT IN ('L','C','R') THEN
                            line_string(doc_id) := line_string(doc_id) || ' horizontal="right" ';
                         END IF;
                         line_string(doc_id) := line_string(doc_id) || ' indent="'||documents(doc_id).formats(i).indent_right||'"'; 
                    END IF;

                    line_string(doc_id) := line_string(doc_id) || '/>';
                END IF;

                
                IF documents(doc_id).formats(i).horizontal_align IS NOT NULL OR 
                   documents(doc_id).formats(i).vertical_align IS NOT NULL OR 
                   NVL(documents(doc_id).formats(i).wrap_text, FALSE) = TRUE OR 
                   NVL(documents(doc_id).formats(i).rotate_text_degree, 0) != 0 OR 
                   NVL(documents(doc_id).formats(i).indent_left, 0) != 0 OR 
                   NVL(documents(doc_id).formats(i).indent_right, 0) != 0 
                THEN
                    line_string(doc_id) := line_string(doc_id) || '</xf>';
                ELSE
                    line_string(doc_id) := line_string(doc_id) || '/>';
                END IF;
                
                IF LENGTH(line_string(doc_id)) > 3500 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
                
            END LOOP;
        END IF;        
        
        line_string(doc_id) := line_string(doc_id) || '</cellXfs>';

        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
        
        
        
        IF documents(doc_id).have_hyperlinks = TRUE OR documents(doc_id).have_internal_hyperlinks = TRUE THEN
            line_string(doc_id) := '<cellStyles count="2">';
            line_string(doc_id) := line_string(doc_id) ||'<cellStyle name="Hyperlink" xfId="1" builtinId="8"/>';
        ELSE
            line_string(doc_id) := '<cellStyles count="1">';
        END IF;
        line_string(doc_id) := line_string(doc_id) ||'<cellStyle name="Normal" xfId="0" builtinId="0"/>';
        line_string(doc_id) := line_string(doc_id) ||'</cellStyles>';
        
        
        line_string(doc_id) := line_string(doc_id) ||'<dxfs count="0"/>';
        line_string(doc_id) := line_string(doc_id) ||'<tableStyles count="0" defaultTableStyle="TableStyleMedium9" defaultPivotStyle="PivotStyleLight16"/>';
        
        line_string(doc_id) := NULL;
        
        IF documents(doc_id).fills.LAST IS NOT NULL THEN
                   
            
            show_header := TRUE;
            
            FOR i IN documents(doc_id).fills.FIRST .. documents(doc_id).fills.LAST LOOP
                            
                IF documents(doc_id).fills(i).color IS NOT NULL THEN
                    
                    IF show_header = TRUE THEN
                        line_string(doc_id) := line_string(doc_id) ||'<colors><mruColors>';
                        show_header := FALSE;
                    END IF;

                    line_string(doc_id) := line_string(doc_id) ||'<color rgb="'||documents(doc_id).fills(i).color||'"/>';

                END IF;
                       
            END LOOP;
            
            IF show_header = FALSE THEN
                line_string(doc_id) := line_string(doc_id) ||'</mruColors></colors>';
            END IF;
                
        END IF;

        line_string(doc_id) := line_string(doc_id) ||'</styleSheet>';
        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
        
        add_xml(blob_file, 'xl/styles.xml', file_content2);
        
        dbms_lob.close(file_content2);
        ------------------------------------------------------------------------
        print_clob(file_content2, 'xl/styles.xml');



        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 8/12');
        -- xl/sharedStrings.xm
        IF LENGTH(documents(doc_id).shared_strings) > 0 OR LENGTH(shared_strings_buffer(doc_id)) > 0 OR documents(doc_id).shared_strings_buffer.LAST IS NOT NULL THEN
        
            dbms_lob.createtemporary(file_content2, TRUE);
            dbms_lob.open(file_content2, dbms_lob.lob_readwrite);
           
            line_string(doc_id) := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10)||'<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="'||documents(doc_id).last_shared_string_num||'" uniqueCount="'||documents(doc_id).last_shared_string_num||'">';----
            dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
           
            -- Append shared strings from buffer
            IF shared_strings_buffer(doc_id) IS NOT NULL THEN
                dbms_lob.writeappend(documents(doc_id).shared_strings, LENGTH(shared_strings_buffer(doc_id)), shared_strings_buffer(doc_id));
                shared_strings_buffer(doc_id) := NULL;
            END IF;
           
            IF documents(doc_id).shared_strings_buffer.LAST IS NOT NULL THEN
            
                FOR buffer_id IN documents(doc_id).shared_strings_buffer.FIRST .. documents(doc_id).shared_strings_buffer.LAST LOOP
                
                    -- Append shared strings
                    dbms_lob.append(file_content2,  documents(doc_id).shared_strings_buffer(buffer_id));
                    
                    dbms_lob.freetemporary(documents(doc_id).shared_strings_buffer(buffer_id));
                
                END LOOP;
            
            END IF;
            
            documents(doc_id).shared_strings_buffer.DELETE;
            
            IF DBMS_LOB.getlength(documents(doc_id).shared_strings) > 0 THEN
                dbms_lob.append(file_content2,  documents(doc_id).shared_strings);
                documents(doc_id).shared_strings := initialize_clob;
            END IF;
            

            -- Release CLOB memory
            dbms_lob.freetemporary(documents(doc_id).shared_strings);
           
            line_string(doc_id) := '</sst>';
            dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
           
            add_xml(blob_file, 'xl/sharedStrings.xml', file_content2);
          
            -- Release CLOB memory
            dbms_lob.close(file_content2);
            
        END IF;
        ------------------------------------------------------------------------
        print_clob(file_content2, 'xl/sharedStrings.xml');
        
        
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 9/12');
        -- xl/theme/theme1.xml
        file_content := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10);
        file_content := file_content || '<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme"><a:themeElements><a:clrScheme name="Office"><a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1><a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1><a:dk2><a:srgbClr val="1F497D"/></a:dk2><a:lt2><a:srgbClr val="EEECE1"/></a:lt2><a:accent1><a:srgbClr val="4F81BD"/></a:accent1><a:accent2><a:srgbClr val="C0504D"/></a:accent2><a:accent3><a:srgbClr val="9BBB59"/></a:accent3><a:accent4><a:srgbClr val="8064A2"/></a:accent4><a:accent5><a:srgbClr val="4BACC6"/></a:accent5><a:accent6><a:srgbClr val="F79646"/></a:accent6><a:hlink><a:srgbClr val="0000FF"/></a:hlink><a:folHlink><a:srgbClr val="800080"/></a:folHlink></a:clrScheme><a:fontScheme name="Office"><a:majorFont><a:latin typeface="Cambria"/><a:ea typeface=""/><a:cs typeface=""/><a:font script="Jpan" typeface="MS P????"/>'||
        '<a:font script="Hang" typeface="?? ??"/><a:font script="Hans" typeface="??"/>'||
        '<a:font script="Hant" typeface="????"/><a:font script="Arab" typeface="Times New Roman"/><a:font script="Hebr" typeface="Times New Roman"/><a:font script="Thai" typeface="Tahoma"/><a:font script="Ethi" typeface="Nyala"/><a:font script="Beng" typeface="Vrinda"/><a:font script="Gujr" typeface="Shruti"/><a:font script="Khmr" typeface="MoolBoran"/><a:font script="Knda" typeface="Tunga"/><a:font script="Guru" typeface="Raavi"/><a:font script="Cans" typeface="Euphemia"/><a:font script="Cher" typeface="Plantagenet Cherokee"/><a:font script="Yiii" typeface="Microsoft Yi Baiti"/><a:font script="Tibt" typeface="Microsoft Himalaya"/><a:font script="Thaa" typeface="MV Boli"/><a:font script="Deva" typeface="Mangal"/><a:font script="Telu" typeface="Gautami"/><a:font script="Taml" typeface="Latha"/><a:font script="Syrc" typeface="Estrangelo Edessa"/><a:font script="Orya" typeface="Kalinga"/><a:font script="Mlym" typeface="Kartika"/><a:font script="Laoo" typeface="DokChampa"/>'||
        '<a:font script="Sinh" typeface="Iskoola Pota"/><a:font script="Mong" typeface="Mongolian Baiti"/><a:font script="Viet" typeface="Times New Roman"/><a:font script="Uigh" typeface="Microsoft Uighur"/></a:majorFont><a:minorFont><a:latin typeface="Calibri"/><a:ea typeface=""/><a:cs typeface=""/><a:font script="Jpan" typeface="MS P????"/><a:font script="Hang" typeface="?? ??"/><a:font script="Hans" typeface="??"/><a:font script="Hant" typeface="????"/><a:font script="Arab" typeface="Arial"/><a:font script="Hebr" typeface="Arial"/><a:font script="Thai" typeface="Tahoma"/><a:font script="Ethi" typeface="Nyala"/><a:font script="Beng" typeface="Vrinda"/><a:font script="Gujr" typeface="Shruti"/><a:font script="Khmr" typeface="DaunPenh"/><a:font script="Knda" typeface="Tunga"/><a:font script="Guru" typeface="Raavi"/><a:font script="Cans" typeface="Euphemia"/><a:font script="Cher" typeface="Plantagenet Cherokee"/><a:font script="Yiii" typeface="Microsoft Yi Baiti"/>'||
        '<a:font script="Tibt" typeface="Microsoft Himalaya"/><a:font script="Thaa" typeface="MV Boli"/><a:font script="Deva" typeface="Mangal"/><a:font script="Telu" typeface="Gautami"/><a:font script="Taml" typeface="Latha"/><a:font script="Syrc" typeface="Estrangelo Edessa"/><a:font script="Orya" typeface="Kalinga"/><a:font script="Mlym" typeface="Kartika"/><a:font script="Laoo" typeface="DokChampa"/><a:font script="Sinh" typeface="Iskoola Pota"/><a:font script="Mong" typeface="Mongolian Baiti"/><a:font script="Viet" typeface="Arial"/><a:font script="Uigh" typeface="Microsoft Uighur"/></a:minorFont></a:fontScheme><a:fmtScheme name="Office"><a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="50000"/><a:satMod val="300000"/></a:schemeClr></a:gs><a:gs pos="35000"><a:schemeClr val="phClr"><a:tint val="37000"/><a:satMod val="300000"/></a:schemeClr></a:gs>'||'
        <a:gs pos="100000"><a:schemeClr val="phClr"><a:tint val="15000"/><a:satMod val="350000"/></a:schemeClr></a:gs></a:gsLst><a:lin ang="16200000" scaled="1"/></a:gradFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:shade val="51000"/><a:satMod val="130000"/></a:schemeClr></a:gs><a:gs pos="80000"><a:schemeClr val="phClr"><a:shade val="93000"/><a:satMod val="130000"/></a:schemeClr></a:gs><a:gs pos="100000"><a:schemeClr val="phClr"><a:shade val="94000"/><a:satMod val="135000"/></a:schemeClr></a:gs></a:gsLst><a:lin ang="16200000" scaled="0"/></a:gradFill></a:fillStyleLst><a:lnStyleLst><a:ln w="9525" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"><a:shade val="95000"/><a:satMod val="105000"/></a:schemeClr></a:solidFill><a:prstDash val="solid"/></a:ln><a:ln w="25400" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/>'||
        '</a:ln><a:ln w="38100" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln></a:lnStyleLst><a:effectStyleLst><a:effectStyle><a:effectLst><a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0"><a:srgbClr val="000000"><a:alpha val="38000"/></a:srgbClr></a:outerShdw></a:effectLst></a:effectStyle><a:effectStyle><a:effectLst><a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0"><a:srgbClr val="000000"><a:alpha val="35000"/></a:srgbClr></a:outerShdw></a:effectLst></a:effectStyle><a:effectStyle><a:effectLst><a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0"><a:srgbClr val="000000"><a:alpha val="35000"/></a:srgbClr></a:outerShdw></a:effectLst><a:scene3d><a:camera prst="orthographicFront"><a:rot lat="0" lon="0" rev="0"/></a:camera><a:lightRig rig="threePt" dir="t"><a:rot lat="0" lon="0" rev="1200000"/></a:lightRig></a:scene3d>'||
        '<a:sp3d><a:bevelT w="63500" h="25400"/></a:sp3d></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="40000"/><a:satMod val="350000"/></a:schemeClr></a:gs><a:gs pos="40000"><a:schemeClr val="phClr"><a:tint val="45000"/><a:shade val="99000"/><a:satMod val="350000"/></a:schemeClr></a:gs><a:gs pos="100000"><a:schemeClr val="phClr"><a:shade val="20000"/><a:satMod val="255000"/></a:schemeClr></a:gs></a:gsLst><a:path path="circle"><a:fillToRect l="50000" t="-80000" r="50000" b="180000"/></a:path></a:gradFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="80000"/><a:satMod val="300000"/></a:schemeClr></a:gs><a:gs pos="100000"><a:schemeClr val="phClr"><a:shade val="30000"/><a:satMod val="200000"/></a:schemeClr></a:gs></a:gsLst><a:path path="circle">'||
        '<a:fillToRect l="50000" t="50000" r="50000" b="50000"/></a:path></a:gradFill></a:bgFillStyleLst></a:fmtScheme></a:themeElements><a:objectDefaults/><a:extraClrSchemeLst/></a:theme>';
        add_xml(blob_file, 'xl/theme/theme1.xml', file_content);
        ------------------------------------------------------------------------
        print_clob(file_content, 'xl/theme/theme1.xml');



        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 10/12');
        -- xl/worksheets/sheetN.xml
        IF documents(doc_id).sheets.LAST IS NOT NULL THEN
                      
            FOR i IN documents(doc_id).sheets.FIRST .. documents(doc_id).sheets.LAST LOOP

                dbms_lob.createtemporary(file_content2, TRUE);
                dbms_lob.open(file_content2, dbms_lob.lob_readwrite);

                top_right_column := documents(doc_id).sheets(i).top_right_column;
                last_row := documents(doc_id).sheets(i).last_row_num;

                line_string(doc_id) := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10);
                line_string(doc_id) := line_string(doc_id) || '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">';
                line_string(doc_id) := line_string(doc_id) || '<dimension ref="A1:'||REPLACE(column_numeric2alpha(top_right_column), '@', 'A')||REPLACE(last_row, '0', '1')||'"/>';
                line_string(doc_id) := line_string(doc_id) || '<sheetViews>';
                line_string(doc_id) := line_string(doc_id) || '<sheetView ';
                IF i = 1 THEN
                    line_string(doc_id) := line_string(doc_id) || ' tabSelected="1" ';
                END IF;
                line_string(doc_id) := line_string(doc_id) || ' workbookViewId="0">';
				
				-- Freeze panes
                IF documents(doc_id).sheets(i).freeze_panes_horizontal IS NOT NULL AND documents(doc_id).sheets(i).freeze_panes_vertical IS NULL THEN
                    line_string(doc_id) := line_string(doc_id) || '<pane ySplit="'||documents(doc_id).sheets(i).freeze_panes_horizontal||'" topLeftCell="A'||(documents(doc_id).sheets(i).freeze_panes_horizontal+1)||'" state="frozenSplit"/>';
                    line_string(doc_id) := line_string(doc_id) || '<selection pane="bottomLeft" activeCell="A'||(documents(doc_id).sheets(i).freeze_panes_horizontal+1)||'" sqref="A'||(documents(doc_id).sheets(i).freeze_panes_horizontal+1)||'"/>';
                ELSIF documents(doc_id).sheets(i).freeze_panes_horizontal IS NULL AND documents(doc_id).sheets(i).freeze_panes_vertical IS NOT NULL THEN
                    line_string(doc_id) := line_string(doc_id) || '<pane xSplit="'||documents(doc_id).sheets(i).freeze_panes_vertical||'" topLeftCell="'||column_numeric2alpha((documents(doc_id).sheets(i).freeze_panes_vertical+1))||'1" activePane="topRight" state="frozenSplit"/>';
                    line_string(doc_id) := line_string(doc_id) || '<selection pane="topRight"/>';
                ELSIF documents(doc_id).sheets(i).freeze_panes_horizontal IS NOT NULL AND documents(doc_id).sheets(i).freeze_panes_vertical IS NOT NULL THEN
                    line_string(doc_id) := line_string(doc_id) || '<pane xSplit="'||documents(doc_id).sheets(i).freeze_panes_vertical||'" ySplit="'||documents(doc_id).sheets(i).freeze_panes_horizontal||'" topLeftCell="'||column_numeric2alpha((documents(doc_id).sheets(i).freeze_panes_vertical+1))||(documents(doc_id).sheets(i).freeze_panes_vertical+1)||'" activePane="bottomRight" state="frozenSplit"/>';
                    line_string(doc_id) := line_string(doc_id) || '<selection pane="bottomLeft" activeCell="A'||(documents(doc_id).sheets(i).freeze_panes_vertical)||'" sqref="A'||(documents(doc_id).sheets(i).freeze_panes_vertical)||'"/>';
                    line_string(doc_id) := line_string(doc_id) || '<selection pane="topRight" activeCell="B'||(documents(doc_id).sheets(i).freeze_panes_horizontal)||'" sqref="B'||(documents(doc_id).sheets(i).freeze_panes_horizontal)||'"/>';
                    line_string(doc_id) := line_string(doc_id) || '<selection pane="bottomRight"/>';
                END IF;
				
                line_string(doc_id) := line_string(doc_id) || '<selection/>';
                line_string(doc_id) := line_string(doc_id) || '</sheetView>';
                line_string(doc_id) := line_string(doc_id) || '</sheetViews>';
                line_string(doc_id) := line_string(doc_id) || '<sheetFormatPr defaultRowHeight="15"/>';
                
                IF top_right_column > 0 THEN
                    line_string(doc_id) := line_string(doc_id) || '<cols>';
                END IF;
                
                IF documents(doc_id).sheets(i).column_properites.LAST IS NOT NULL THEN
                    FOR col IN documents(doc_id).sheets(i).column_properites.FIRST .. documents(doc_id).sheets(i).column_properites.LAST LOOP
                        line_string(doc_id) := line_string(doc_id) || '<col min="'||column_alpha2numeric(documents(doc_id).sheets(i).column_properites(col).column_name)||'" max="'||column_alpha2numeric(documents(doc_id).sheets(i).column_properites(col).column_name)||'" width="'||REPLACE(TO_CHAR(documents(doc_id).sheets(i).column_properites(col).width),',', '.')||'" hidden="'||NVL(documents(doc_id).sheets(i).column_properites(col).hidden, 0)||'" bestFit="1" customWidth="1"/>'; 
                    END LOOP;
                ELSIF top_right_column > 0 THEN
                    line_string(doc_id) := line_string(doc_id) || '<col min="'||top_right_column||'" max="'||top_right_column||'" width="10.140625" bestFit="1" customWidth="1"/>';
                END IF;
                
                IF top_right_column > 0 THEN
                    line_string(doc_id) := line_string(doc_id) || '</cols>';
                END IF;
                
                line_string(doc_id) := line_string(doc_id) || '<sheetData>';
                dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                
                line_string(doc_id) := NULL;
                  
                -- Append data from buffer
                IF sheet_data_buffer(doc_id) IS NOT NULL THEN
                    dbms_lob.writeappend(documents(doc_id).sheets(i).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id)); 
                    sheet_data_buffer(doc_id) := NULL;
                END IF;
                
                IF INSTR(documents(doc_id).sheets(i).sheet_data, 'spans="1:1"') > 0 THEN
                    documents(doc_id).sheets(i).sheet_data := REPLACE(documents(doc_id).sheets(i).sheet_data, 'spans="1:1"', 'spans="1:'||REPLACE(documents(doc_id).sheets(i).top_right_column, '0', '1')||'"'); 
                END IF;
        
                IF documents(doc_id).sheets(i).sheet_data_buffer.LAST IS NOT NULL THEN
                
                    FOR buffer_id IN documents(doc_id).sheets(i).sheet_data_buffer.FIRST .. documents(doc_id).sheets(i).sheet_data_buffer.LAST LOOP
                    
                       -- Append rows
                        DBMS_LOB.append(file_content2, documents(doc_id).sheets(i).sheet_data_buffer(buffer_id));

                        dbms_lob.freetemporary(documents(doc_id).sheets(i).sheet_data_buffer(buffer_id));
                    
                    END LOOP;
                
                END IF;
                
                documents(doc_id).sheets(i).sheet_data_buffer.DELETE;
                
                -- Write content from buffer if buffer is not empty
                IF DBMS_LOB.getlength(documents(doc_id).sheets(i).sheet_data) > 0 THEN
                    DBMS_LOB.append(file_content2, documents(doc_id).sheets(i).sheet_data);
                END IF;
                
                documents(doc_id).sheets(i).sheet_data := initialize_clob;

                line_string(doc_id) :=  '</sheetData>';
                
                -- Append merged cells information tags
                IF documents(doc_id).sheets(i).merged_cells.LAST IS NOT NULL THEN
                    line_string(doc_id) := line_string(doc_id)|| '<mergeCells count="'||documents(doc_id).sheets(i).merged_cells.LAST||'">';
                    FOR merged_id IN documents(doc_id).sheets(i).merged_cells.FIRST .. documents(doc_id).sheets(i).merged_cells.LAST LOOP
                       line_string(doc_id) := line_string(doc_id)|| '<mergeCell ref="'||documents(doc_id).sheets(i).merged_cells(merged_id).merged_cells||'"/>';  
                       IF  LENGTH(line_string(doc_id)) > 3500 THEN
                            dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                            line_string(doc_id) := NULL;
                       END IF;
                    END LOOP;
                    line_string(doc_id) := line_string(doc_id)|| '</mergeCells>';
                END IF;
                
                -- Set Auto Filter
                IF documents(doc_id).sheets(i).filter_from IS NOT NULL AND documents(doc_id).sheets(i).filter_to IS NOT NULL THEN 
                    line_string(doc_id) := line_string(doc_id)||'<autoFilter ref="'||documents(doc_id).sheets(i).filter_from||':'||documents(doc_id).sheets(i).filter_to||'"></autoFilter>'; 
                END IF;
                
                -- Add hyperlinks
                IF documents(doc_id).sheets(i).hyperlinks.LAST IS NOT NULL OR 
                   documents(doc_id).sheets(i).internal_hyperlinks.LAST IS NOT NULL 
                THEN
                    line_string(doc_id) := line_string(doc_id)||'<hyperlinks>';
                END IF;
                
                
                IF documents(doc_id).sheets(i).hyperlinks.LAST IS NOT NULL THEN
    
                    FOR h IN documents(doc_id).sheets(i).hyperlinks.FIRST .. documents(doc_id).sheets(i).hyperlinks.LAST LOOP
                                                
                        -- Empty buffer if it is almost full  
                        IF  LENGTH(line_string(doc_id)) > 3000 THEN
                            dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                            line_string(doc_id) := NULL;
                        END IF;
                        
                       line_string(doc_id) := line_string(doc_id)||'<hyperlink ref="'||documents(doc_id).sheets(i).hyperlinks(h).cell||'" r:id="rId'||h||'"/>'; 

                    END LOOP;
 
                END IF;
                
                IF documents(doc_id).sheets(i).internal_hyperlinks.LAST IS NOT NULL THEN
                    
                    FOR h IN documents(doc_id).sheets(i).internal_hyperlinks.FIRST .. documents(doc_id).sheets(i).internal_hyperlinks.LAST LOOP
                                                
                        -- Empty buffer if it is almost full  
                        IF  LENGTH(line_string(doc_id)) > 3000 THEN
                            dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                            line_string(doc_id) := NULL;
                        END IF;

                       line_string(doc_id) := line_string(doc_id)||'<hyperlink ref="'||documents(doc_id).sheets(i).internal_hyperlinks(h).cell||'" location="'||documents(doc_id).sheets(i).internal_hyperlinks(h).hyperlink||'" display=""/>'; 

                    END LOOP;
                    
                END IF;
                
                IF documents(doc_id).sheets(i).hyperlinks.LAST IS NOT NULL OR 
                   documents(doc_id).sheets(i).internal_hyperlinks.LAST IS NOT NULL 
                THEN
                    line_string(doc_id) := line_string(doc_id)||'</hyperlinks>';
                END IF;
                
                
                
                -- Set page margins parameters
                line_string(doc_id) := line_string(doc_id) || '<pageMargins left="'||NVL(REPLACE(TO_CHAR(documents(doc_id).sheets(i).margins_left), ',', '.'), '0.7')|| 
                                                              '" right="'||NVL(REPLACE(TO_CHAR(documents(doc_id).sheets(i).margins_right), ',', '.'), '0.7')|| 
                                                              '" top="'||NVL(REPLACE(TO_CHAR(documents(doc_id).sheets(i).margins_top), ',', '.'), '0.75')|| 
                                                              '" bottom="'||NVL(REPLACE(TO_CHAR(documents(doc_id).sheets(i).margins_bottom), ',', '.'), '0.75')|| 
                                                              '" header="'||NVL(REPLACE(TO_CHAR(documents(doc_id).sheets(i).margins_header), ',', '.'), '0.3')|| 
                                                              '" footer="'||NVL(REPLACE(TO_CHAR(documents(doc_id).sheets(i).margins_footer), ',', '.'), '0.3')||'"/>';
                                                              
    
                line_string(doc_id) := line_string(doc_id) || '<pageSetup paperSize="'||NVL(documents(doc_id).sheets(i).paper_size, 9)||'"'; 
                IF documents(doc_id).sheets(i).orientation = 'landscape' THEN 
                    line_string(doc_id) := line_string(doc_id) || ' orientation="landscape"';
                END IF;
                line_string(doc_id) := line_string(doc_id) || '/>';
                
               
                -- Empty buffer if it is almost full  
                IF  LENGTH(line_string(doc_id)) > 3000 THEN
                    dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                    line_string(doc_id) := NULL;
                END IF;
                
                IF documents(doc_id).sheets(i).header_text IS NOT NULL OR documents(doc_id).sheets(i).footer_text IS NOT NULL THEN 
                
                    line_string(doc_id) := line_string(doc_id) || '<headerFooter>';
                    
                    IF documents(doc_id).sheets(i).header_text IS NOT NULL THEN 
                        line_string(doc_id) := line_string(doc_id) || '<oddHeader>'||CHR(38)||'amp;C'||dbms_xmlgen.convert(documents(doc_id).sheets(i).header_text)||'</oddHeader>'; 
                    END IF;
                    
                    -- Empty buffer if it is almost full  
                    IF  LENGTH(line_string(doc_id)) > 3000 THEN
                        dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                        line_string(doc_id) := NULL;
                    END IF;
                    
                    IF documents(doc_id).sheets(i).footer_text IS NOT NULL THEN 
                        line_string(doc_id) := line_string(doc_id) || '<oddFooter>'||CHR(38)||'amp;C'||dbms_xmlgen.convert(documents(doc_id).sheets(i).footer_text)||'</oddFooter>'; 
                    END IF;
                    
                    line_string(doc_id) := line_string(doc_id) || '</headerFooter>';

                END IF;
                
                -- Comments drawing
                IF documents(doc_id).sheets(i).comments.LAST IS NOT NULL THEN
                    line_string(doc_id) := line_string(doc_id) || '<legacyDrawing r:id="rId1"/>';
                END IF;
                                                                                  
                line_string(doc_id) := line_string(doc_id) || '</worksheet>';
                dbms_lob.writeappend(file_content2, LENGTH(line_string(doc_id)), line_string(doc_id));
                line_string(doc_id) := NULL;
                  
                add_xml(blob_file, 'xl/worksheets/sheet'||i||'.xml', file_content2);
                
                print_clob(file_content2, 'xl/worksheets/sheet'||i||'.xml');
                
                dbms_lob.close(file_content2);

            END LOOP;
            
            dbms_lob.freetemporary(file_content2);
            
        END IF;
        
        
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 11/12');
        -- docProps/core.xml
        file_content := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10);
        file_content := file_content || '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        file_content := file_content || '<dc:creator>'||dbms_xmlgen.convert(NVL(documents(doc_id).author, 'www.oraexcel.com'))||'</dc:creator>';
        file_content := file_content || '<cp:lastModifiedBy>'||dbms_xmlgen.convert(NVL(documents(doc_id).author, 'www.oraexcel.com'))||'</cp:lastModifiedBy>';
        file_content := file_content || '<dcterms:created xsi:type="dcterms:W3CDTF">' || TO_CHAR( CURRENT_TIMESTAMP, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM' ) || '</dcterms:created>';
        file_content := file_content || '<dcterms:modified xsi:type="dcterms:W3CDTF">' || TO_CHAR( CURRENT_TIMESTAMP, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM' ) || '</dcterms:modified>';
        file_content := file_content || '</cp:coreProperties>';
        add_xml(blob_file, 'docProps/core.xml', file_content);
        ------------------------------------------------------------------------
        print_clob(file_content, 'docProps/core.xml');
              
        
          
       DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Formatting ... Step 12/12');
        -- docProps/app.xml
        file_content := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'||CHR(10);
        file_content := file_content || '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">';
        file_content := file_content || '<Application>Microsoft Excel</Application>';
        file_content := file_content || '<DocSecurity>0</DocSecurity>';
        file_content := file_content || '<ScaleCrop>false</ScaleCrop>';
        file_content := file_content || '<HeadingPairs>';
        file_content := file_content || '<vt:vector size="2" baseType="variant">';
        file_content := file_content || '<vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant>';
        file_content := file_content || '<vt:variant><vt:i4>'||last_sheet||'</vt:i4></vt:variant>';
        file_content := file_content || '</vt:vector>';
        file_content := file_content || '</HeadingPairs>';
        file_content := file_content || '<TitlesOfParts>';
        file_content := file_content || '<vt:vector size="'||last_sheet||'" baseType="lpstr">';
        IF last_sheet IS NOT NULL THEN
            FOR i IN first_sheet .. last_sheet LOOP
                file_content := file_content || '<vt:lpstr>'||dbms_xmlgen.convert(documents(doc_id).sheets(i).sheet_name)||'</vt:lpstr>'; 
            END LOOP;
        END IF;
        file_content := file_content || '</vt:vector>';
        file_content := file_content || '</TitlesOfParts>';
        file_content := file_content || '<LinksUpToDate>false</LinksUpToDate>';
        file_content := file_content || '<SharedDoc>false</SharedDoc>';
        file_content := file_content || '<HyperlinksChanged>false</HyperlinksChanged>';
        file_content := file_content || '<AppVersion>12.0000</AppVersion>';
        file_content := file_content || '</Properties>';
        add_xml(blob_file, 'docProps/app.xml', file_content);
        ------------------------------------------------------------------------
        print_clob(file_content, 'docProps/app.xml');


        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Finishing ...');
                
        compress_document( blob_file );
        
        -- Release sheet memory
        documents(doc_id).sheets.DELETE;
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Done!'); 
    
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure save_to_blob'||SQLCODE||' '||SQLERRM);
    END;
    ------------------------------------------------------------------------

    PROCEDURE set_cell_font (cell_name VARCHAR2, 
                             font_name VARCHAR2, 
                             font_size PLS_INTEGER, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id, 
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                             row_id PLS_INTEGER DEFAULT current_row_id) 
    IS        
        font fonts_type; 
    BEGIN
        
        current_cell_number := column_alpha2numeric(cell_name);
        font.font_name := font_name; 
        font.font_size := font_size; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(cell_name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).format_font_id := add_font(font, NULL, doc_id); 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_font'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_default_font (font_name VARCHAR2 DEFAULT 'Calibri', 
                                font_size PLS_INTEGER DEFAULT 11, 
                                doc_id PLS_INTEGER DEFAULT current_doc_id) 
    IS
        default_font default_font_type;
    BEGIN
        default_font.font_name := font_name;
        default_font.font_size := font_size; 
        documents(doc_id).default_font := default_font;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_default_font'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
     
    PROCEDURE set_cell_bold(name VARCHAR2, 
                            doc_id PLS_INTEGER DEFAULT current_doc_id, 
                            sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                            row_id PLS_INTEGER DEFAULT current_row_id) 
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).bold := TRUE; 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_bold'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_italic(name VARCHAR2, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                              row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).italic := TRUE; 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_italic'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_underline(name VARCHAR2, 
                                 doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                 sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                 row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).underline := TRUE; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_underline'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_color (name VARCHAR2, 
                              color VARCHAR2, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                              row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).color := color; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_color'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_bg_color (name VARCHAR2, 
                                 color VARCHAR2, 
                                 doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                 sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                 row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).bg_color := color; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_bg_color'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_align_left (name VARCHAR2, 
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).horizontal_align := 'L'; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_align_left'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_align_center (name VARCHAR2, 
                                     doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                     sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                     row_id PLS_INTEGER DEFAULT current_row_id) 
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).horizontal_align := 'C'; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_align_center'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_align_right (name VARCHAR2, 
                                    doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                    row_id PLS_INTEGER DEFAULT current_row_id)
    IS        
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).horizontal_align := 'R'; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_align_right'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_vert_align_top (name VARCHAR2, 
                                       doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                       sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                       row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).vertical_align := 'T'; 
        cell_formatted := TRUE;
        
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_vert_align_top'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_vert_align_middle (name VARCHAR2, 
                                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                          sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                          row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).vertical_align := 'M'; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_vert_align_middle'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_vert_align_bottom (name VARCHAR2, 
                                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                          sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                          row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).vertical_align := 'B'; 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_vert_align_bottom'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_wrap_text (name VARCHAR2, 
                                  doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                  sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                  row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).wrap_text := TRUE; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_wrap_text'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_border_top (name VARCHAR2, 
                                   style VARCHAR2 DEFAULT 'thin', 
                                   color VARCHAR2 DEFAULT '00000000', 
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name :=  UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_top := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_top_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_top_color := color; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_border_top'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_border_bottom (name VARCHAR2, 
                                      style VARCHAR2 DEFAULT 'thin', 
                                      color VARCHAR2 DEFAULT '00000000', 
                                      doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                      sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                      row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_bottom := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_bottom_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_bottom_color := color; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_border_bottom'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_border_left (name VARCHAR2, 
                                    style VARCHAR2 DEFAULT 'thin', 
                                    color VARCHAR2 DEFAULT '00000000', 
                                    doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                    row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_left := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_left_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_left_color := color; 
        cell_formatted := TRUE;
                
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_border_left'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_border_right (name VARCHAR2, 
                                     style VARCHAR2 DEFAULT 'thin', 
                                     color VARCHAR2 DEFAULT '00000000', 
                                     doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                     sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                     row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_right := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_right_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_right_color := color; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_border_right'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_border (name VARCHAR2, 
                               style VARCHAR2 DEFAULT 'thin', 
                               color VARCHAR2 DEFAULT '00000000', 
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                               row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_top := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_top_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_top_color := color; 
        
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_bottom := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_bottom_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_bottom_color := color; 
        
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_left := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_left_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_left_color := color; 
        
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_right := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_right_style := style; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).border_right_color := color; 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_border'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------

    
    PROCEDURE query_to_sheet(query CLOB, 
                             show_column_names BOOLEAN DEFAULT TRUE, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id, 
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id) 
    IS
        curid    NUMBER;
        desctab  DBMS_SQL.DESC_TAB;
        colcnt   NUMBER;
        namevar  VARCHAR2(4000);
        numvar   NUMBER;
        datevar  DATE;
        ret NUMBER;
        tmp_query CLOB; 
    BEGIN

        tmp_query := query;

        -- Open cursor
        curid := DBMS_SQL.open_cursor;

        -- Parse query
        DBMS_SQL.parse(curid, tmp_query, DBMS_SQL.native );
            
        -- Get column names and types
        DBMS_SQL.DESCRIBE_COLUMNS(curid, colcnt, desctab);
     
        -- Add row for column names    
        IF show_column_names = TRUE THEN
            add_row(doc_id, sheet_id);        
        END IF;
        
        -- Get column names and prepare column types
        FOR i IN 1 .. colcnt LOOP
            
            IF desctab(i).col_type IN ( 2, 100, 101 ) THEN
            
                DBMS_SQL.DEFINE_COLUMN(curid, i, numvar);
                IF show_column_names = TRUE THEN
                   set_cell_value(column_numeric2alpha(i), desctab(i).col_name, doc_id, sheet_id);
                END IF;
                 
            ELSIF desctab(i).col_type IN ( 12, 178, 179, 180, 181 , 231 ) THEN
     
               DBMS_SQL.DEFINE_COLUMN(curid, i, datevar);
                IF show_column_names = TRUE THEN
                   set_cell_value(column_numeric2alpha(i), desctab(i).col_name, doc_id, sheet_id);
                END IF;            
     
            ELSE -- in ( 1, 8, 9, 96, 112 )
            
                DBMS_SQL.DEFINE_COLUMN(curid, i, namevar, 4000);
                IF show_column_names = TRUE THEN
                   set_cell_value(column_numeric2alpha(i), desctab(i).col_name, doc_id, sheet_id);
                END IF;

            END IF;
            
        END LOOP;

        ret := DBMS_SQL.EXECUTE(curid);

        -- Fetch rows with DBMS_SQL package
        WHILE DBMS_SQL.FETCH_ROWS(curid) > 0 LOOP


            -- Add row for every fetched row
            add_row(doc_id, sheet_id);

            FOR i IN 1 .. colcnt LOOP

                IF (desctab(i).col_type IN(1, 96, 9)) THEN
                    -- Get STRING column valus and add it to spreadsheet
                    DBMS_SQL.COLUMN_VALUE(curid, i, namevar);
                    set_cell_value(column_numeric2alpha(i), namevar, doc_id, sheet_id);
                    
                ELSIF (desctab(i).col_type = 2) THEN
                    
                    -- Get NUMERIC column valus and add it to spreadsheet
                    DBMS_SQL.COLUMN_VALUE(curid, i, numvar);
                    set_cell_value(column_numeric2alpha(i), numvar, doc_id, sheet_id);
                    
                ELSIF (desctab(i).col_type = 12) THEN
                    
                    -- Get DATE column valus and add it to spreadsheet
                    DBMS_SQL.COLUMN_VALUE(curid, i, datevar);
                    set_cell_value(column_numeric2alpha(i), datevar, doc_id, sheet_id);
                    
                END IF;
                
            END LOOP;
           
        END LOOP;

        -- Close cursor
        DBMS_SQL.CLOSE_CURSOR(curid);
  
    EXCEPTION
        WHEN others THEN
            DBMS_SQL.CLOSE_CURSOR(curid);
            RAISE_APPLICATION_ERROR(-20100, 'Procedure query_to_sheet'||SQLCODE||' '||SQLERRM);
    END;
    ---------------------------------------------------------------------------
    
    PROCEDURE save_to_file(directory_name VARCHAR2, file_name VARCHAR2, doc_id PLS_INTEGER DEFAULT current_doc_id) IS
        blob_file BLOB;
    BEGIN
 
        save_to_blob(blob_file, doc_id);
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Writting to file ...');       
        
        blob2file(blob_file, directory_name, file_name );
        
        DBMS_APPLICATION_INFO.set_client_info('ORA_EXCEL Done!');
        
    EXCEPTION
        WHEN UTL_FILE.FILE_OPEN THEN
            RAISE_APPLICATION_ERROR(-20100, 'File '||file_name||' is open, please close it first'||SQLCODE||' '||SQLERRM||CHR(10));
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure save_to_file'||SQLCODE||' '||SQLERRM||CHR(10));
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_row_height(height NUMBER, doc_id PLS_INTEGER DEFAULT current_doc_id, sheet_id PLS_INTEGER DEFAULT current_sheet_id, row_id PLS_INTEGER DEFAULT current_row_id) IS
    BEGIN
        
        documents(doc_id).sheets(sheet_id).row_height := height; 

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_row_height'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
     PROCEDURE add_merged_cell(merged_cells VARCHAR2, doc_id PLS_INTEGER DEFAULT current_doc_id, sheet_id PLS_INTEGER DEFAULT current_sheet_id) IS
        column_id PLS_INTEGER;
    BEGIN
        
        IF documents(doc_id).sheets(sheet_id).merged_cells.LAST IS NOT NULL THEN

            FOR i IN documents(doc_id).sheets(sheet_id).merged_cells.FIRST .. documents(doc_id).sheets(sheet_id).merged_cells.LAST LOOP
               
                IF documents(doc_id).sheets(sheet_id).merged_cells(i).merged_cells = UPPER(merged_cells) THEN 
                    column_id := i;
                    EXIT;
                END IF; 
                      
            END LOOP;

        END IF;
        
        IF column_id IS NULL THEN
            documents(doc_id).sheets(sheet_id).merged_cells.EXTEND;
            column_id := documents(doc_id).sheets(sheet_id).merged_cells.LAST;
        END IF;

        documents(doc_id).sheets(sheet_id).merged_cells(column_id).merged_cells := UPPER(merged_cells); 

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure add_merged_cell'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE merge_cells (cell_from VARCHAR2, 
                           cell_to VARCHAR2, 
                           doc_id PLS_INTEGER DEFAULT current_doc_id, 
                           sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                           row_id PLS_INTEGER DEFAULT current_row_id)
    IS
        cells_to_add VARCHAR2(4000);
    BEGIN

        -- Push data from buffer if buffer is almost full
        IF LENGTH(sheet_data_buffer(doc_id)) > 32750 THEN

            dbms_lob.writeappend(documents(doc_id).sheets(sheet_id).sheet_data, LENGTH(sheet_data_buffer(doc_id)), sheet_data_buffer(doc_id));
            sheet_data_buffer(doc_id) := NULL;
        END IF;
        
        --Prepare cells to add
        cells_to_add := NULL;
        FOR i IN (column_alpha2numeric(cell_from) + 1) .. column_alpha2numeric(cell_to) LOOP
           cells_to_add := cells_to_add || '<c r="'||column_numeric2alpha(i)||row_id||'" s="\2"/>';
           documents(doc_id).sheets(sheet_id).top_right_column := documents(doc_id).sheets(sheet_id).top_right_column + 1;
        END LOOP;

        add_merged_cell(cell_from||row_id||':'||cell_to||row_id, doc_id, sheet_id);
        
        current_cell_number := column_alpha2numeric(cell_from);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(cell_from)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).merge_cells := TRUE; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).merged_cells_cell_from := cell_from;   
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).merges_cells_cell_to := cell_to;  
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cells_to_add := cells_to_add;  
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure merge_cells'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE merge_rows (cell_from VARCHAR2, 
                          cell_to PLS_INTEGER, 
                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                          sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                          row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        add_merged_cell(cell_from||row_id||':'||cell_from||(row_id + cell_to), doc_id, sheet_id);

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure merge_rows'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_formula(name VARCHAR2, 
                              formula VARCHAR2, 
                              doc_id PLS_INTEGER DEFAULT current_doc_id, 
                              sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                              row_id PLS_INTEGER DEFAULT current_row_id) 
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).formula := dbms_xmlgen.convert(REGEXP_REPLACE(formula,'[[:cntrl:]]','')); 

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure merge_rows'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cell_rotate_text (name VARCHAR2,
                                    degrees INTEGER, 
                                    doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                    row_id PLS_INTEGER DEFAULT current_row_id) 
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).rotate_text_degree := degrees; 
        cell_formatted := TRUE;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_align_center'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE download_file(file_name VARCHAR2, 
                            doc_id PLS_INTEGER DEFAULT current_doc_id)  
    IS
        blob_file BLOB;
        blob_size INTEGER; 
    BEGIN
    
        save_to_blob(blob_file, doc_id);
        
        -- Get BLOB size
        blob_size := dbms_lob.getlength(blob_file);
             
        -- Print content type header for MS Excel
        owa_util.mime_header('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', FALSE, NULL);
        
        -- Put BLOB size header
        htp.p('Content-length: '|| blob_size);
        
        -- Set file name that will be suggested when download dialog appears
        htp.p('Content-Disposition: attachment; filename="'||file_name||'"');
        
        -- Close header
        owa_util.http_header_close;
             
        -- Download BLOB
        wpg_docload.download_file(blob_file);
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure download_file'||SQLCODE||' '||SQLERRM);
    END;  
    ----------------------------------------------------------------------------
-- New    
    PROCEDURE set_sheet_margins(left_margin NUMBER,
                                right_margin NUMBER, 
                                top_margin NUMBER,
                                bottom_margin NUMBER,
                                header_margin NUMBER,
                                footer_margin NUMBER, 
                                sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN
        
        documents(doc_id).sheets(sheet_id).margins_left :=  left_margin / 2.54; 
        documents(doc_id).sheets(sheet_id).margins_right :=  right_margin / 2.54; 
        documents(doc_id).sheets(sheet_id).margins_top :=  top_margin / 2.54; 
        documents(doc_id).sheets(sheet_id).margins_bottom :=  bottom_margin / 2.54; 
        documents(doc_id).sheets(sheet_id).margins_header :=  header_margin / 2.54; 
        documents(doc_id).sheets(sheet_id).margins_footer :=  footer_margin / 2.54;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_sheet_margins'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_sheet_landscape(sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN
         
         documents(doc_id).sheets(sheet_id).orientation := 'landscape'; 
         
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_sheet_landscape'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------                           
    
    PROCEDURE set_sheet_paper_size(paper_size INTEGER,
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id) 
    IS
    BEGIN
    
        IF paper_size BETWEEN 1 AND 41 THEN
            documents(doc_id).sheets(sheet_id).paper_size := paper_size; 
        ELSE
             RAISE_APPLICATION_ERROR(-20100, 'Procedure set_sheet_paper_size - supported paper sizes are between 1 and 41');
        END IF;
    
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_sheet_paper_size'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------  
    
    PROCEDURE set_sheet_header_text(header_text VARCHAR2,
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN
    
        documents(doc_id).sheets(sheet_id).header_text := SUBSTR(header_text, 1, 1000); 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_sheet_header_text'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------  
    
    PROCEDURE set_sheet_footer_text(footer_text VARCHAR2,
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN
    
        documents(doc_id).sheets(sheet_id).footer_text := SUBSTR(footer_text, 1, 1000); 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_sheet_footer_text'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------  

    PROCEDURE set_cell_hyperlink(name VARCHAR2, 
                                 hyperlink VARCHAR2,
                                 doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                 sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                 row_id PLS_INTEGER DEFAULT current_row_id)
    IS
        current_hyperlink_id INTEGER;
    BEGIN
    
        documents(doc_id).sheets(current_sheet_id).hyperlinks.EXTEND;
        current_hyperlink_id := documents(doc_id).sheets(current_sheet_id).hyperlinks.LAST;
        
        documents(doc_id).sheets(current_sheet_id).hyperlinks(current_hyperlink_id).cell := name||row_id; 
        documents(doc_id).sheets(current_sheet_id).hyperlinks(current_hyperlink_id).hyperlink := hyperlink; 
        documents(doc_id).have_hyperlinks := TRUE;
        
        set_cell_underline(name);
        set_cell_color(name, '0000ff');
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_hyperlink'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------  
    
    PROCEDURE set_cell_internal_hyperlink(name VARCHAR2, 
                                          hyperlink VARCHAR2,
                                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                          sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                          row_id PLS_INTEGER DEFAULT current_row_id)
    IS
        current_hyperlink_id INTEGER;
    BEGIN
    
        documents(doc_id).sheets(current_sheet_id).internal_hyperlinks.EXTEND;
        current_hyperlink_id := documents(doc_id).sheets(current_sheet_id).internal_hyperlinks.LAST;
        
        documents(doc_id).sheets(current_sheet_id).internal_hyperlinks(current_hyperlink_id).cell := name||row_id; 
        documents(doc_id).sheets(current_sheet_id).internal_hyperlinks(current_hyperlink_id).hyperlink := hyperlink; 
        documents(doc_id).have_internal_hyperlinks := TRUE;
        
        set_cell_underline(name);
        set_cell_color(name, '0000ff');
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_internal_hyperlink'||SQLCODE||' '||SQLERRM);
    END;
    ---------------------------------------------------------------------------- 
    
    PROCEDURE set_cell_indent_left(name VARCHAR2, 
                                   indent INTEGER,
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).indent_left := indent; 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_indent_left'||SQLCODE||' '||SQLERRM);
    END; 
    ----------------------------------------------------------------------------  
    
    PROCEDURE set_cell_indent_right(name VARCHAR2, 
                                   indent INTEGER,
                                   doc_id PLS_INTEGER DEFAULT current_doc_id, 
                                   sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                                   row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN

        current_cell_number := column_alpha2numeric(name);
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).cell_name := UPPER(name)||row_id; 
        documents(doc_id).sheets(current_sheet_id).current_cell(current_cell_number).indent_right := indent; 
        cell_formatted := TRUE;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_indent_right'||SQLCODE||' '||SQLERRM);
    END;      
    ----------------------------------------------------------------------------  
    
    PROCEDURE set_cell_comment(name VARCHAR2, 
                               autohr VARCHAR2,
                               comment_text VARCHAR2,
                               comment_box_width NUMBER,
                               comment_box_height NUMBER,
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                               row_id PLS_INTEGER DEFAULT current_row_id)  
    IS
        current_comment_id INTEGER;
    BEGIN

        documents(doc_id).sheets(current_sheet_id).comments.EXTEND;
        current_comment_id := documents(doc_id).sheets(current_sheet_id).comments.LAST;
        
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).cell := name||row_id; 
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).author := SUBSTR(autohr, 1, 30); 
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).comment_text := SUBSTR(comment_text, 1, 1000); 
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).box_width := comment_box_width; 
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).box_height := comment_box_height; 
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).row_id := row_id - 1; 
        documents(doc_id).sheets(sheet_id).comments(current_comment_id).column_id := column_alpha2numeric(name) - 1; 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_comment'||SQLCODE||' '||SQLERRM);
    END;
    ---------------------------------------------------------------------------           
    
    PROCEDURE hide_column(name VARCHAR2,  
                          doc_id PLS_INTEGER DEFAULT current_doc_id, 
                          sheet_id PLS_INTEGER DEFAULT current_sheet_id)   
    IS
        column_id INTEGER;
    BEGIN
    
       IF documents(doc_id).sheets(sheet_id).column_properites.LAST IS NOT NULL THEN

            FOR i IN documents(doc_id).sheets(sheet_id).column_properites.FIRST .. documents(doc_id).sheets(sheet_id).column_properites.LAST LOOP
                IF documents(doc_id).sheets(sheet_id).column_properites(i).column_name = UPPER(name) THEN 
                    column_id := i;
                    EXIT;
                END IF;       
            END LOOP;

        END IF;
        
        IF column_id IS NULL THEN
            documents(doc_id).sheets(sheet_id).column_properites.EXTEND;
            column_id := documents(doc_id).sheets(sheet_id).column_properites.LAST;
        END IF;

        documents(doc_id).sheets(sheet_id).column_properites(column_id).column_name := UPPER(name); 
        documents(doc_id).sheets(sheet_id).column_properites(column_id).hidden := 1; 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure hide_column'||SQLCODE||' '||SQLERRM);
    
    END;                                                                    
    --------------------------------------------------------------------------- 
    
    PROCEDURE hide_row(doc_id PLS_INTEGER DEFAULT current_doc_id, 
                       sheet_id PLS_INTEGER DEFAULT current_sheet_id, 
                       row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
        
        documents(doc_id).sheets(sheet_id).hide_row := TRUE; 

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure hide_row'||SQLCODE||' '||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE set_cells_filter(cell_from VARCHAR2, 
                               cell_to VARCHAR2,
                               doc_id PLS_INTEGER DEFAULT current_doc_id, 
                               sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN

        documents(doc_id).sheets(sheet_id).filter_from := cell_from; 
        documents(doc_id).sheets(sheet_id).filter_to := cell_to; 
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_filter'||SQLCODE||' '||SQLERRM);
    END;      
    ----------------------------------------------------------------------------
    
    FUNCTION raw2num(value IN RAW) RETURN NUMBER IS
    BEGIN
        
           RETURN UTL_RAW.cast_to_binary_integer(value, UTL_RAW.little_endian);

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure raw2num: '||SQLCODE||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION blob2num (p_blob BLOB, p_len INTEGER, p_pos INTEGER)
       RETURN NUMBER
    IS
    BEGIN
       RETURN UTL_RAW.cast_to_binary_integer (
                 DBMS_LOB.SUBSTR (p_blob, p_len, p_pos),
                 UTL_RAW.little_endian);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION raw2varchar2 (p_raw RAW, p_encoding VARCHAR2)
       RETURN VARCHAR2
    IS
    BEGIN
       RETURN COALESCE (
                 UTL_I18N.raw_to_char (p_raw, p_encoding),
                 UTL_I18N.raw_to_char (
                    p_raw,
                    UTL_I18N.map_charset (p_encoding,
                                          UTL_I18N.GENERIC_CONTEXT,
                                          UTL_I18N.IANA_TO_ORACLE)));
    END;
    ----------------------------------------------------------------------------
    
    
    FUNCTION extract_file(p_zipped_blob    BLOB,
                          p_file_name      VARCHAR2,
                          p_encoding       VARCHAR2 := NULL)
       RETURN BLOB
    IS
       t_tmp        BLOB;
       t_ind        INTEGER;
       t_hd_ind     INTEGER;
       t_fl_ind     INTEGER;
       t_encoding   VARCHAR2 (32767);
       t_len        INTEGER;
       c_END_OF_CENTRAL_DIRECTORY constant raw(4) := hextoraw( '504B0506' ); -- End of central directory signature
    BEGIN
       t_ind := DBMS_LOB.getlength (p_zipped_blob) - 21;

       LOOP
          EXIT WHEN t_ind < 1
                    OR DBMS_LOB.SUBSTR (p_zipped_blob, 4, t_ind) =
                         c_END_OF_CENTRAL_DIRECTORY;
          t_ind := t_ind - 1;
       END LOOP;

       --
       IF t_ind <= 0
       THEN
          RETURN NULL;
       END IF;

       --
       t_hd_ind := blob2num (p_zipped_blob, 4, t_ind + 16) + 1;

       FOR i IN 1 .. blob2num (p_zipped_blob, 2, t_ind + 8)
       LOOP
          IF p_encoding IS NULL
          THEN
             IF UTL_RAW.bit_and (
                   DBMS_LOB.SUBSTR (p_zipped_blob, 1, t_hd_ind + 9),
                   HEXTORAW ('08')) = HEXTORAW ('08')
             THEN
                t_encoding := 'AL32UTF8';                                  -- utf8
             ELSE
                t_encoding := 'US8PC437';                      -- IBM codepage 437
             END IF;
          ELSE
             t_encoding := p_encoding;
          END IF;

          IF p_file_name =
                raw2varchar2 (
                   DBMS_LOB.SUBSTR (p_zipped_blob,
                                    blob2num (p_zipped_blob, 2, t_hd_ind + 28),
                                    t_hd_ind + 46),
                   t_encoding)
          THEN
             t_len := blob2num (p_zipped_blob, 4, t_hd_ind + 24); -- uncompressed length

             IF t_len = 0
             THEN
                IF SUBSTR (p_file_name, -1) IN ('/', '\')
                THEN                                           -- directory/folder
                   RETURN NULL;
                ELSE                                                 -- empty file
                   RETURN EMPTY_BLOB ();
                END IF;
             END IF;

             --
             IF DBMS_LOB.SUBSTR (p_zipped_blob, 2, t_hd_ind + 10) =
                   HEXTORAW ('0800')                                    -- deflate
             THEN
                t_fl_ind := blob2num (p_zipped_blob, 4, t_hd_ind + 42);
                t_tmp := HEXTORAW ('1F8B0800000000000003');         -- gzip header
                DBMS_LOB.COPY (
                   t_tmp,
                   p_zipped_blob,
                   blob2num (p_zipped_blob, 4, t_hd_ind + 20),
                   11,
                     t_fl_ind
                   + 31
                   + blob2num (p_zipped_blob, 2, t_fl_ind + 27) -- File name length
                   + blob2num (p_zipped_blob, 2, t_fl_ind + 29) -- Extra field length
                                                               );
                DBMS_LOB.append (
                   t_tmp,
                   UTL_RAW.CONCAT (
                      DBMS_LOB.SUBSTR (p_zipped_blob, 4, t_hd_ind + 16)   -- CRC32
                                                                       ,
                      little_endian (t_len)                 -- uncompressed length
                                           ));
                RETURN UTL_COMPRESS.lz_uncompress (t_tmp);
             END IF;

             --
             IF DBMS_LOB.SUBSTR (p_zipped_blob, 2, t_hd_ind + 10) =
                   HEXTORAW ('0000')        -- The file is stored (no compression)
             THEN
                t_fl_ind := blob2num (p_zipped_blob, 4, t_hd_ind + 42);
                DBMS_LOB.createtemporary (t_tmp, TRUE);
                DBMS_LOB.COPY (
                   t_tmp,
                   p_zipped_blob,
                   t_len,
                   1,
                     t_fl_ind
                   + 31
                   + blob2num (p_zipped_blob, 2, t_fl_ind + 27) -- File name length
                   + blob2num (p_zipped_blob, 2, t_fl_ind + 29) -- Extra field length
                                                               );
                RETURN t_tmp;
             END IF;
          END IF;

          t_hd_ind :=
               t_hd_ind
             + 46
             + blob2num (p_zipped_blob, 2, t_hd_ind + 28)      -- File name length
             + blob2num (p_zipped_blob, 2, t_hd_ind + 30)    -- Extra field length
             + blob2num (p_zipped_blob, 2, t_hd_ind + 32);  -- File comment length
       END LOOP;

       --
       RETURN NULL;
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION file_to_blob( directory IN VARCHAR2, file IN VARCHAR2 ) RETURN BLOB
    IS
        file_lob BFILE;
        file_blob BLOB;
    BEGIN
        
        file_lob := BFILENAME(directory, file);
        
        DBMS_LOB.open( file_lob, DBMS_LOB.file_readonly );
        DBMS_LOB.createtemporary( file_blob, true );
        DBMS_LOB.loadfromfile(file_blob, file_lob, DBMS_LOB.lobmaxsize);
        DBMS_LOB.close( file_lob );
        
        RETURN file_blob;
        
    EXCEPTION
        WHEN others THEN
            IF DBMS_LOB.isopen( file_lob ) = 1 THEN
                DBMS_LOB.close( file_lob );
            END IF;
            IF DBMS_LOB.istemporary( file_blob ) = 1 THEN
                DBMS_LOB.freetemporary( file_blob );
            END IF;
            RAISE_APPLICATION_ERROR(-20100, 'Procedure file_to_blob:'||SQLCODE||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION blob_to_clob(src_blob IN BLOB) RETURN CLOB IS
        v_clob CLOB;
        v_amount NUMBER DEFAULT 2000;
        v_offset NUMBER DEFAULT 1;
        v_buffer VARCHAR2(32767);
        v_length PLS_INTEGER := DBMS_LOB.getlength(src_blob);
    BEGIN

        DBMS_LOB.createtemporary(v_clob, TRUE);

        DBMS_LOB.open(v_clob, DBMS_LOB.lob_readwrite);

        WHILE v_offset <= v_length LOOP
           
            v_buffer := utl_raw.cast_to_varchar2(DBMS_LOB.substr(src_blob, v_amount, v_offset));

            IF length(v_buffer) > 0 THEN
                DBMS_LOB.writeappend(v_clob, length(v_buffer), v_buffer);
            END IF;

            v_offset := v_offset + v_amount;
            EXIT WHEN v_offset > v_length;
            
        END LOOP;

        RETURN v_clob;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure blob_to_clob:' ||SQLCODE||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    PROCEDURE open_document(directory_name VARCHAR2, file_name VARCHAR2) IS
        blob_file BLOB := EMPTY_BLOB();
        clob_file CLOB := EMPTY_CLOB();
        i PLS_INTEGER;
        num_fmt_id INTEGER;
        apply_number_format INTEGER;
        format_line VARCHAR2(1000);
        format_code VARCHAR2(1000);
    BEGIN

        -- Release memory for currently opened docuement
        loaded_document := EMPTY_BLOB();
        loaded_shared_strings := EMPTY_CLOB();
        loaded_sheet := EMPTY_CLOB();
        loaded_row_id := NULL;
        loaded_row_string := EMPTY_CLOB();
        loaded_styles := loaded_styles_empty;
        loaded_date_system := NULL;

        -- Get local charset
        local_charset := SUBSTR(sys_context('USERENV', 'LANGUAGE'), INSTR(sys_context('USERENV', 'LANGUAGE'), '.', -1) + 1, LENGTH(sys_context('USERENV', 'LANGUAGE')));
        
        -- Load file to BLOB
        loaded_document := file_to_blob(directory_name, file_name);

        -- Extract shared striings
        blob_file := extract_file(loaded_document, 'xl/sharedStrings.xml');

        -- If sharedStrings.xml exists extract it to CLOB
        IF DBMS_LOB.getlength(blob_file) > 0 THEN
            loaded_shared_strings := blob_to_clob(blob_file);
        ELSE
            loaded_shared_strings := EMPTY_CLOB();
        END IF;
            
        loaded_sheet := EMPTY_CLOB();
        
        
        
        blob_file := extract_file(loaded_document, 'xl/styles.xml');
        
        -- If styles.xml exists extract it to CLOB
        IF DBMS_LOB.getlength(blob_file) > 0 THEN
            
            clob_file := blob_to_clob(blob_file);
            
            i := 0;
            LOOP
                i := i + 1;
                format_line := REGEXP_SUBSTR(clob_file, '\<xf numFmtId\=\"(.*?)\/\>', INSTR(clob_file, '<cellXfs'), i);

                
                num_fmt_id := NVL(TO_NUMBER(REPLACE(REPLACE(REGEXP_SUBSTR(format_line, 'numFmtId\=\"([[:digit:]]+)\"'), 'numFmtId="', ''), '"', '')), 0);

                apply_number_format := NVL(TO_NUMBER(REPLACE(REPLACE(REGEXP_SUBSTR(format_line, 'applyNumberFormat\=\"([[:digit:]]+)\"'), 'applyNumberFormat="', ''), '"', '')), 0);
                
                
                
                IF NVL(num_fmt_id, 0) IN (14, 15, 16, 17, 18, 19, 20, 21, 22, 45, 46, 47) THEN
                    loaded_styles(i) := 'D'; -- Date 
                ELSE
                    loaded_styles(i) := 'S'; -- String  
                END IF;
                
                
                IF NVL(apply_number_format, 0) = 1 AND NVL(loaded_styles(i), '*') != 'D' THEN
                    loaded_styles(i) := 'N'; -- Number
                END IF;
                
                
                IF num_fmt_id >= 164 THEN
                              
                   loaded_styles(i) := 'N'; -- Number
                                  
                   format_line := REGEXP_SUBSTR(clob_file, '\<numFmt[[:space:]]numFmtId\=\"'||TO_CHAR(num_fmt_id)||'"[[:space:]]formatCode\=\"(.*?)\"', 1, 1);

                   IF format_line IS NOT NULL THEN

                        format_code := REPLACE(REPLACE(REGEXP_SUBSTR(format_line, 'formatCode\=\"(.*?)\"'), 'formatCode="', ''), '"', '');

                        -- Custom format containst date codes
                        IF REGEXP_LIKE(format_code, '[d|m|y|h|s]') = TRUE THEN

                            loaded_styles(i) := 'D'; -- Date
                                
                        END IF;
                            
                   END IF;
                       
                END IF; 
                
               -- dbms_output.put_line('loaded_styles('||i||'):'||loaded_styles(i)); 
                
            EXIT WHEN format_line IS NULL;

            END LOOP; 
              
        ELSE

            loaded_styles := loaded_styles_empty;
            
        END IF;


        loaded_date_system := '1900';
        
        blob_file := extract_file(loaded_document, 'xl/workbook.xml');
        
        -- If styles.xml exists extract it to CLOB
        IF DBMS_LOB.getlength(blob_file) > 0 THEN

            clob_file := blob_to_clob(blob_file);
           
            IF INSTR(clob_file, 'date1904="true"') > 0 OR INSTR(clob_file, 'date1904="1"') > 0 THEN
                loaded_date_system := '1904';
            END IF;
            
        END IF;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100,'Procedure open_document: '||SQLCODE||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    FUNCTION get_format_type(format_number INTEGER) RETURN VARCHAR2 IS
    BEGIN

        RETURN loaded_styles(format_number + 1);

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure get_format_type:'||SQLCODE||SQLERRM);
    END;
    
    PROCEDURE close_document IS
    BEGIN
        
        -- Release memory for currently opened docuement
        loaded_document := EMPTY_BLOB();
        loaded_shared_strings := EMPTY_CLOB();
        loaded_sheet := EMPTY_CLOB();
        loaded_row_id := NULL;
        loaded_row_string := EMPTY_CLOB();
        loaded_styles := loaded_styles_empty;
        loaded_date_system := NULL;
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure close_document: '||SQLCODE||SQLERRM);
    END;
    
    ----------------------------------------------------------------------------
    PROCEDURE open_sheet(sheet_id PLS_INTEGER) IS
        blob_file BLOB := EMPTY_BLOB();
    BEGIN
        
        loaded_row_string := EMPTY_CLOB();
        
        IF NVL(DBMS_LOB.getlength(loaded_document), 0) = 0 THEN
            --
            RAISE_APPLICATION_ERROR(-20100, 'Document not opened, please open document using open_document procedure first');
        END IF;
      
        blob_file := extract_file(loaded_document, 'xl/worksheets/sheet'||sheet_id||'.xml');
       
        IF DBMS_LOB.getlength(blob_file) > 0 THEN
            loaded_sheet := blob_to_clob(blob_file);
        ELSE
            RAISE_APPLICATION_ERROR(-20100, 'Sheet with id '||sheet_id||' does not exists');
        END IF;

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure open_sheet integer: '||SQLCODE||SQLERRM);
    END;
    ----------------------------------------------------------------------------
    
    
    PROCEDURE open_sheet(sheet_name VARCHAR2) IS
        blob_file BLOB := EMPTY_BLOB();
        clob_file CLOB := EMPTY_CLOB();
        sheet_id INTEGER;
    BEGIN


        IF NVL(DBMS_LOB.getlength(loaded_document), 0) > 0 THEN
            blob_file := extract_file(loaded_document, 'xl/workbook.xml');
        ELSE
            --Document not opened, please open document using open_document procedure first
            RAISE_APPLICATION_ERROR(-20100, 'Document not opened, please open document using open_document procedure first');
        END IF;

        clob_file := blob_to_clob(blob_file);

        sheet_id := TO_NUMBER(
                        REGEXP_SUBSTR(
                            REGEXP_SUBSTR(
                                REGEXP_SUBSTR(clob_file,
                                              'sheet[[:space:]]name\=\"'||LOWER(sheet_name)||'\"[[:space:]]sheetId\=\"(.*?)\"', 1, 1, 'i'
                                              ), 
                                'sheetId\=\"(.*?)\"'
                            ), 
                            '([[:digit:]]+)'
                        )
                    );

        IF sheet_id IS NOT NULL THEN
            open_sheet(sheet_id);
        ELSE
            RAISE_APPLICATION_ERROR(-20100, 'Sheet '||sheet_name||' does not exists');
        END IF;          
                
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure open_sheet varchar2'||SQLCODE||SQLERRM);
    END;
    
    
    
    
    FUNCTION get_cell_value(cell_name VARCHAR2) RETURN cell_value_type IS
        row_id INTEGER;
        cell_value_string VARCHAR2(100);
        cell_value cell_value_type;
        format_id INTEGER;
        number_value NUMBER;
        
        PROCEDURE set_number_value IS
        BEGIN
--            dbms_output.put_line('set_number_value'); 
            cell_value.number_value := TO_NUMBER(cell_value_string,  TRANSLATE(cell_value_string, '012345678', '999999999'), 'nls_numeric_characters=''.,''');
            cell_value.date_value := NULL;
            cell_value.varchar2_value := TO_CHAR(cell_value.number_value);
            cell_value.value := cell_value.varchar2_value;
            cell_value.type := 'N';
        END;
        
        PROCEDURE set_varchar2_value IS
        BEGIN
--            dbms_output.put_line('set_varchar2_value'); 
            cell_value.varchar2_value := regexp_substr(loaded_shared_strings, '\<t\>(.*?)\<\/t\>', 1, TO_NUMBER(cell_value_string) + 1);
            cell_value.varchar2_value := CONVERT(SUBSTR(cell_value.varchar2_value, 4, LENGTH(cell_value.varchar2_value) -7), local_charset, 'UTF8');
            cell_value.date_value := NULL;
            cell_value.number_value := NULL;
            cell_value.value := cell_value.varchar2_value;
            cell_value.type := 'S';
        END;
        
        PROCEDURE set_date_value IS
        BEGIN
--            dbms_output.put_line('set_date_value'); 
            number_value := TO_NUMBER(cell_value_string,  TRANSLATE(cell_value_string, '012345678', '999999999'), 'nls_numeric_characters=''.,''');
            IF loaded_date_system = '1904' THEN
                cell_value.date_value := TO_DATE('01.01.'||loaded_date_system,'dd.mm.yyyy') + number_value;
            ELSE
                cell_value.date_value := TO_DATE('01.01.'||loaded_date_system,'dd.mm.yyyy') + number_value - 2;
            END IF;
            cell_value.number_value := number_value;
            cell_value.varchar2_value := TO_CHAR(cell_value.date_value, 'yyyy-mm-dd hh24:mi:ss');
            cell_value.value := cell_value.varchar2_value;
            cell_value.type := 'D';
        END;
        
    BEGIN

        IF NVL(DBMS_LOB.getlength(loaded_document), 0) = 0 THEN
            --Document not opened, please open document using open_document procedure first
            RAISE_APPLICATION_ERROR(-20100, 'Document not opened, please open document using open_document procedure first');
        END IF;
        
         IF NVL(DBMS_LOB.getlength(loaded_sheet), 0) = 0 THEN
            --Sheet opened, please open sheet using open_sheet procedure first
            RAISE_APPLICATION_ERROR(-20100, 'Sheet opened, please open sheet using open_sheet procedure first');
        END IF;
        
        cell_value.varchar2_value := NULL;
        cell_value.number_value := NULL;
        cell_value.varchar2_value := NULL;
             
                     
        row_id := REGEXP_SUBSTR(cell_name, '[[:digit:]+].*');
        
        -- If row is not loaded load it to cache
        IF row_id != NVL(loaded_row_id, 0) THEN
            loaded_row_string := REGEXP_SUBSTR(loaded_sheet ,'\<row[[:space:]]r\=\"'||row_id||'\"(.*?)\<\/row\>');
            loaded_row_id := row_id;
        END IF;

        -- If row is loaded to chache    
        IF NVL(DBMS_LOB.getlength(loaded_row_string), 0) > 0 THEN
            
            -- Get cell value string
            cell_value_string := REGEXP_SUBSTR(REGEXP_SUBSTR(REGEXP_SUBSTR(loaded_row_string, 'r\=\"'||cell_name||'\"(.*?)\<\/v\>'), '\<v\>(.*?)\<\/v\>'), '[0-9.]+', 1, 1, 'i');

            -- If value is varchar2
            --IF REGEXP_LIKE(loaded_row_string, 'r\=\"'||cell_name||'\"(.*?)t\=\"s\"(.*?)>') THEN
            IF REGEXP_LIKE(loaded_row_string, 'r="'||cell_name||'"[s"=t ]+>') THEN

                set_varchar2_value;
                
            -- If there is foramt for cell                
            ELSIF REGEXP_LIKE(loaded_row_string, 'r\=\"'||cell_name||'\"(.*?)s\=\"(.*)\"') = TRUE THEN
                            
                -- Get format id
                format_id := TO_NUMBER(REPLACE(REPLACE(REGEXP_SUBSTR(REGEXP_SUBSTR(loaded_row_string, 'r="'||cell_name||'"[s"=0-9 ]+>'), 's="([[:digit:]]+)"'), 's="', ''), '"', ''));

                IF format_id IS NOT NULL THEN
                    CASE get_format_type(format_id)
                     
                        WHEN 'N' THEN
                             set_number_value;
                        WHEN 'D' THEN
                             set_date_value;
                        WHEN 'S' THEN
                             set_varchar2_value;
                        ELSE 
                        
                            NULL;
                        
                    END CASE; 

                ELSE

                    set_number_value;            

                END IF;

            ELSE
                set_number_value;
            END IF;

        END IF;
        
        RETURN cell_value;
        
        
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure get_cell_value '||SQLCODE||SQLERRM);
    END;
    
    FUNCTION get_last_row RETURN INTEGER IS
    BEGIN

        RETURN TO_NUMBER(REGEXP_SUBSTR(REGEXP_SUBSTR(loaded_sheet, 'r="([[:digit:]]+)"', NVL(INSTR(loaded_sheet , '<row', -1), 1)), '([[:digit:]]+)'));

    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure get_last_row '||SQLCODE||SQLERRM);
    END;
    
    PROCEDURE set_1904_date_system IS
    BEGIN
        date_system := 1904;
    END;
    
    PROCEDURE set_1900_date_system IS
    BEGIN
        date_system := 1900;
    END;
    
    PROCEDURE set_document_author(author VARCHAR2, doc_id PLS_INTEGER DEFAULT current_doc_id) IS
    BEGIN
        documents(doc_id).author := SUBSTR(author, 1, 1000); 
    END;
    
    PROCEDURE add_style (style_name VARCHAR2,
                         font_name VARCHAR2 DEFAULT NULL,
                         font_size PLS_INTEGER DEFAULT NULL,
                         formula VARCHAR2 DEFAULT NULL,
                         bold BOOLEAN DEFAULT FALSE,
                         italic BOOLEAN DEFAULT FALSE,
                         underline BOOLEAN DEFAULT FALSE,
                         color VARCHAR2 DEFAULT NULL,
                         bg_color VARCHAR2 DEFAULT NULL,
                         horizontal_align VARCHAR2 DEFAULT NULL,
                         vertical_align VARCHAR2 DEFAULT NULL,
                         border_top BOOLEAN DEFAULT FALSE,
                         border_top_style VARCHAR2 DEFAULT NULL,
                         border_top_color VARCHAR2 DEFAULT NULL,
                         border_bottom BOOLEAN DEFAULT FALSE,
                         border_bottom_style VARCHAR2 DEFAULT NULL,
                         border_bottom_color VARCHAR2 DEFAULT NULL,
                         border_left BOOLEAN DEFAULT FALSE, 
                         border_left_style VARCHAR2 DEFAULT NULL,
                         border_left_color VARCHAR2 DEFAULT NULL,
                         border_right BOOLEAN DEFAULT FALSE,
                         border_right_style VARCHAR2 DEFAULT NULL, 
                         border_right_color VARCHAR2 DEFAULT NULL, 
                         border BOOLEAN DEFAULT NULL,
                         border_style VARCHAR2 DEFAULT NULL,
                         border_color VARCHAR2 DEFAULT NULL,
                         wrap_text BOOLEAN DEFAULT FALSE,
                         format VARCHAR2 DEFAULT NULL, 
                         rotate_text_degree INTEGER DEFAULT NULL, 
                         indent_left INTEGER DEFAULT NULL, 
                         indent_right INTEGER DEFAULT NULL,  
                         doc_id PLS_INTEGER DEFAULT current_doc_id) 
    IS                
    BEGIN

        documents(doc_id).styles(style_name).style_name := style_name; 
        documents(doc_id).styles(style_name).font_name := font_name;
        documents(doc_id).styles(style_name).font_size := font_size;
        documents(doc_id).styles(style_name).formula := formula;
        documents(doc_id).styles(style_name).bold := bold;
        documents(doc_id).styles(style_name).italic := italic;
        documents(doc_id).styles(style_name).underline := underline;
        documents(doc_id).styles(style_name).color := color;
        documents(doc_id).styles(style_name).bg_color := bg_color;
        documents(doc_id).styles(style_name).horizontal_align := horizontal_align;
        documents(doc_id).styles(style_name).vertical_align := vertical_align;
        documents(doc_id).styles(style_name).border_top := border_top;
        documents(doc_id).styles(style_name).border_top_style := border_top_style;
        documents(doc_id).styles(style_name).border_top_color := border_top_color;
        documents(doc_id).styles(style_name).border_bottom := border_bottom;
        documents(doc_id).styles(style_name).border_bottom_style := border_bottom_style;
        documents(doc_id).styles(style_name).border_bottom_color := border_bottom_color;
        documents(doc_id).styles(style_name).border_left := border_left;
        documents(doc_id).styles(style_name).border_left_style := border_left_style;
        documents(doc_id).styles(style_name).border_left_color := border_left_color;
        documents(doc_id).styles(style_name).border_right := border_right;
        documents(doc_id).styles(style_name).border_right_style := border_right_style;
        documents(doc_id).styles(style_name).border_right_color := border_right_color;
        documents(doc_id).styles(style_name).border := border;
        documents(doc_id).styles(style_name).border_style := border_style;
        documents(doc_id).styles(style_name).border_color := border_color;
        documents(doc_id).styles(style_name).wrap_text := wrap_text;
        documents(doc_id).styles(style_name).format := format;
        documents(doc_id).styles(style_name).rotate_text_degree := rotate_text_degree;
        documents(doc_id).styles(style_name).indent_left := indent_left;
        documents(doc_id).styles(style_name).indent_right := indent_right;
        

    EXCEPTION
        WHEN others THEN      
            RAISE_APPLICATION_ERROR(-20100, 'Procedure add_style '||SQLCODE||SQLERRM);
        
    END;
    
    PROCEDURE set_cell_style(cell_name VARCHAR2, 
                             style_name VARCHAR2, 
                             doc_id PLS_INTEGER DEFAULT current_doc_id,
                             sheet_id PLS_INTEGER DEFAULT current_sheet_id,
                             row_id PLS_INTEGER DEFAULT current_row_id)
    IS
    BEGIN
    
        IF documents(doc_id).styles(style_name).font_name IS NOT NULL OR 
           documents(doc_id).styles(style_name).font_size IS NOT NULL 
        THEN
            set_cell_font(cell_name,
                          NVL(documents(doc_id).styles(style_name).font_name, 'Calibri'),
                          NVL(documents(doc_id).styles(style_name).font_size, 11),
                          doc_id, 
                          sheet_id, 
                          row_id);   
        END IF;
        
        IF documents(doc_id).styles(style_name).formula IS NOT NULL THEN 
            set_cell_formula(cell_name, documents(doc_id).styles(style_name).formula, doc_id, sheet_id, row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).bold = TRUE THEN
            set_cell_bold(cell_name, doc_id, sheet_id, row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).italic = TRUE THEN
            set_cell_italic(cell_name, doc_id, sheet_id, row_id);
        END IF;
    
        IF documents(doc_id).styles(style_name).underline = TRUE THEN
            set_cell_underline(cell_name, doc_id, sheet_id, row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).color IS NOT NULL THEN
            set_cell_color(cell_name, documents(doc_id).styles(style_name).color, doc_id, sheet_id, row_id); 
        END IF;
        
        IF documents(doc_id).styles(style_name).bg_color IS NOT NULL THEN
            set_cell_bg_color(cell_name, documents(doc_id).styles(style_name).bg_color, doc_id, sheet_id, row_id); 
        END IF;
        
        IF documents(doc_id).styles(style_name).horizontal_align IS NOT NULL THEN
        
            CASE documents(doc_id).styles(style_name).horizontal_align
                WHEN 'left' THEN 
                    set_cell_align_left(cell_name, doc_id, sheet_id, row_id);
                WHEN 'right' THEN
                    set_cell_align_right(cell_name, doc_id, sheet_id, row_id);
                WHEN 'center' THEN
                    set_cell_align_center(cell_name, doc_id, sheet_id, row_id);
                ELSE
                    NULL;
            END CASE;
            
        END IF;
        
        IF documents(doc_id).styles(style_name).vertical_align IS NOT NULL THEN
        
            CASE documents(doc_id).styles(style_name).vertical_align
                WHEN 'top' THEN
                    set_cell_vert_align_top(cell_name, doc_id, sheet_id, row_id);
                WHEN 'middle' THEN
                    set_cell_vert_align_middle(cell_name, doc_id, sheet_id, row_id);
                WHEN 'bottom' THEN
                    set_cell_vert_align_bottom(cell_name, doc_id, sheet_id, row_id);
                ELSE
                    NULL;
            END CASE;
        
        END IF;
        
        IF documents(doc_id).styles(style_name).border_top = TRUE THEN
            set_cell_border_top(cell_name, 
                                NVL(documents(doc_id).styles(style_name).border_top_style, 'thin'),
                                NVL(documents(doc_id).styles(style_name).border_top_color, '00000000'),
                                doc_id, 
                                sheet_id, 
                                row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).border_left = TRUE THEN
            set_cell_border_left(cell_name, 
                                 NVL(documents(doc_id).styles(style_name).border_left_style, 'thin'),
                                 NVL(documents(doc_id).styles(style_name).border_left_color, '00000000'),
                                 doc_id, 
                                 sheet_id, 
                                 row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).border_bottom = TRUE THEN
            set_cell_border_bottom(cell_name, 
                                   NVL(documents(doc_id).styles(style_name).border_bottom_style, 'thin'),
                                   NVL(documents(doc_id).styles(style_name).border_bottom_color, '00000000'),
                                   doc_id, 
                                   sheet_id, 
                                   row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).border_right = TRUE THEN
            set_cell_border_right(cell_name, 
                                  NVL(documents(doc_id).styles(style_name).border_right_style, 'thin'),
                                  NVL(documents(doc_id).styles(style_name).border_right_color, '00000000'),
                                  doc_id, 
                                  sheet_id, 
                                  row_id);
        END IF;
        
        IF documents(doc_id).styles(style_name).border = TRUE THEN
        
            set_cell_border_top(cell_name, 
                                NVL(documents(doc_id).styles(style_name).border_style, 'thin'),
                                NVL(documents(doc_id).styles(style_name).border_color, '00000000'),
                                doc_id, 
                                sheet_id, 
                                row_id);
        
            set_cell_border_left(cell_name, 
                                 NVL(documents(doc_id).styles(style_name).border_style, 'thin'),
                                 NVL(documents(doc_id).styles(style_name).border_color, '00000000'),
                                 doc_id, 
                                 sheet_id, 
                                 row_id);
                                 
            set_cell_border_bottom(cell_name, 
                                   NVL(documents(doc_id).styles(style_name).border_style, 'thin'),
                                   NVL(documents(doc_id).styles(style_name).border_color, '00000000'),
                                   doc_id, 
                                   sheet_id, 
                                   row_id);
                                   
             set_cell_border_right(cell_name, 
                                  NVL(documents(doc_id).styles(style_name).border_style, 'thin'),
                                  NVL(documents(doc_id).styles(style_name).border_color, '00000000'),
                                  doc_id, 
                                  sheet_id, 
                                  row_id);
                                  
        END IF;
        
        IF documents(doc_id).styles(style_name).wrap_text = TRUE THEN
            set_cell_wrap_text(cell_name, doc_id, sheet_id, row_id); 
        END IF;
        
        IF documents(doc_id).styles(style_name).format IS NOT NULL THEN
            set_cell_format(cell_name, documents(doc_id).styles(style_name).format, doc_id, sheet_id, row_id); 
        END IF;
        
        IF documents(doc_id).styles(style_name).rotate_text_degree IS NOT NULL THEN
            set_cell_rotate_text(cell_name, documents(doc_id).styles(style_name).rotate_text_degree, doc_id, sheet_id, row_id); 
        END IF;
        
        IF documents(doc_id).styles(style_name).indent_left IS NOT NULL THEN
            set_cell_indent_left(cell_name, documents(doc_id).styles(style_name).indent_left, doc_id, sheet_id, row_id); 
        END IF;
        
        IF documents(doc_id).styles(style_name).indent_right IS NOT NULL THEN
            set_cell_indent_right(cell_name, documents(doc_id).styles(style_name).indent_right, doc_id, sheet_id, row_id); 
        END IF;
        
        
     EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_style - style '||style_name||' does not exists'||SQLCODE||SQLERRM);
        WHEN others THEN     
            RAISE_APPLICATION_ERROR(-20100, 'Procedure set_cell_style '||SQLCODE||SQLERRM);
        
    END;
	
	
	PROCEDURE freeze_panes_horizontal(freeze_columns_number VARCHAR2,
                                      doc_id PLS_INTEGER DEFAULT current_doc_id,
                                      sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN
        documents(doc_id).sheets(sheet_id).freeze_panes_horizontal := freeze_columns_number;
    EXCEPTION
       WHEN others THEN     
            RAISE_APPLICATION_ERROR(-20100, 'Procedure freeze_panes_horizontal:'||SQLCODE||SQLERRM);
        
    END;
     
    
    PROCEDURE freeze_panes_vertical(freeze_rows_number VARCHAR2,
                                    doc_id PLS_INTEGER DEFAULT current_doc_id,
                                    sheet_id PLS_INTEGER DEFAULT current_sheet_id)
    IS
    BEGIN
        documents(doc_id).sheets(sheet_id).freeze_panes_vertical := freeze_rows_number;
    EXCEPTION
       WHEN others THEN     
            RAISE_APPLICATION_ERROR(-20100, 'Procedure freeze_panes_vertical:'||SQLCODE||SQLERRM);
        
    END;
     
    
    
END;
/
