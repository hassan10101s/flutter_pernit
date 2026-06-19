class ApiConstants {
  const ApiConstants._();

  static const login = '/v1/login_u/';
  static const logout = '/v1/auth/api/logout/';
  static const tokenRefresh = '/v1/token/refresh/';
  static const tokenVerify = '/v1/token/verify/';
  static const purchaseOrders = '/v1/auth/erp/purchase-orders/';
  static const purchaseOrderDetails = '/v1/auth/erp/purchase-order-details/';
  static const rawMaterials = '/v1/auth/erp/raw-materials/';
  static const products = '/v1/auth/erp/products/';
  static const receivedRawMaterials = '/v1/auth/erp/received-raw-materials/';
  static const rawMaterialInventory = '/v1/auth/erp/inventory-raw-materials/';
  static const productInventory = '/v1/auth/erp/inventory-products/';
  static const warehouses = '/v1/auth/erp/warehouses/';
  static const allDrivers = '/v1/auth/erp/all-drivers/';
  static const rawMaterialLabSamples =
      '/v1/auth/erp/lab-samples-of-received-raw-materials/';
  static const rawMaterialQualityChecks =
      '/v1/auth/erp/quality-checks-raw-materials/';

  static String rawMaterialAnalysisWorkspace(int sampleId) {
    return '$rawMaterialLabSamples$sampleId/analysis-workspace/';
  }

  static String recordAcceptedRawMaterialQuantity(int batchId) {
    return '$receivedRawMaterials$batchId/record-accepted-quantity/';
  }

  static const addProductStock = '/v1/auth/erp/inventory-products/add-stock/';
}
