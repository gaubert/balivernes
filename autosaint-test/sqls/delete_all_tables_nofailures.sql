/* =============================================================================== */
/* SCHEMA: Delete all AUTOSAINT tables                                                  */
/* AUTHOR: guillaume.aubert@ctbto.org*/
/* DATE	 : 05.02.2008	                                                             */
/* =============================================================================== */

delete from FILEPRODUCT;
delete from FPDESCRIPTION;
delete from GARDS_CAT_TEMPLATE;
delete from GARDS_DETECTORS;
delete from GARDS_NUCL_LIB;
delete from GARDS_NUCL_LINES_LIB;
delete from GARDS_PRODUCT;
delete from GARDS_PRODUCT_TYPE;
delete from GARDS_REFLINE_MASTER;
delete from GARDS_RELEVANT_NUCLIDES;
delete from GARDS_SAMPLE_CAT;
delete from GARDS_STATIONS;
delete from GARDS_USERENV;
delete from GARDS_COMMENTS;
delete from GARDS_EFFICIENCY_CAL;
delete from GARDS_EFFICIENCY_PAIRS;
delete from GARDS_ENERGY_CAL;
delete from GARDS_ENERGY_PAIRS;
delete from GARDS_ENERGY_PAIRS_ORIG;
delete from GARDS_NUCL_IDED;
delete from GARDS_NUCL_IDED_ORIG;
delete from GARDS_PEAKS;
delete from GARDS_PEAKS_ORIG;
delete from GARDS_RESOLUTION_CAL;
delete from GARDS_RESOLUTION_PAIRS;
delete from GARDS_RESOLUTION_PAIRS_ORIG;
delete from GARDS_SAMPLE_AUX;
delete from GARDS_SAMPLE_DATA;
delete from GARDS_SAMPLE_FLAGS;
delete from GARDS_SAMPLE_STATUS;
delete from GARDS_SOH_CHAR_DATA;
delete from GARDS_SOH_NUM_DATA;
delete from GARDS_BASELINE;
delete from GARDS_ENERGY_CAL_COV;
delete from GARDS_QC_RESULTS;
delete from GARDS_RESOLUTION_CAL_COV;
delete from GARDS_NUCL_LINES_IDED;
delete from GARDS_NUCL_LINES_IDED_ORIG;
delete from GARDS_IRF;
delete from GARDS_SPECTRUM;
delete from GARDS_READ_SAMPLE_STATUS;
delete from GARDS_EFFICIENCY_VGSL_PAIRS;

commit;

