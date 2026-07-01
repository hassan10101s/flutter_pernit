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
  static const rawMaterialLabResults =
      '/v1/auth/erp/lab-results-raw-materials/';
  static const rawMaterialPhysicalLabResults =
      '/v1/auth/erp/physical-lab-results-raw-materials/';
  static const productionQualityChecks =
      '/v1/auth/erp/quality-checks-production/';
  static const productionLabSamples = '/v1/auth/erp/lab-samples-of-production/';
  static const productionLabResults = '/v1/auth/erp/lab-results-production/';
  static const productionAnalysisParameters =
      '/v1/auth/erp/analysis-parameters-production/';
  static const productionOrders = '/v1/auth/erp/production-orders/';

  static String rawMaterialAnalysisWorkspace(int sampleId) {
    return '$rawMaterialLabSamples$sampleId/analysis-workspace/';
  }

  static String recordAcceptedRawMaterialQuantity(int batchId) {
    return '$receivedRawMaterials$batchId/record-accepted-quantity/';
  }

  static const addProductStock = '/v1/auth/erp/inventory-products/add-stock/';

  // Notifications
  static const notifications = '/v1/auth/erp/notifications/';
  static const notificationsUnreadCount =
      '/v1/auth/erp/notifications/unread_count/';
  static const notificationsMarkAllRead =
      '/v1/auth/erp/notifications/mark_all_read/';

  // Push device registration
  static const notificationDevices = '/v1/auth/erp/notification-devices/';
  static const notificationDevicesUnregister =
      '/v1/auth/erp/notification-devices/unregister/';

  static String notificationMarkRead(int id) {
    return '$notifications$id/mark_read/';
  }
}
