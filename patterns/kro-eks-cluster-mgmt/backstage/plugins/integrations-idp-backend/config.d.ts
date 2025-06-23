export interface Config {
  /** Optional configurations for the IDP integration
   * @visibility frontend
   */
  app?: {
    /**
     * Kargo URL
     * @visibility frontend
     */
    kargoUrl?: string;
    /**
     * ArgoCD URL
     * @visibility frontend
     */
    argocdUrl?: string;
    /**
     * Argo Workflows URL
     * @visibility frontend
     */
    argoworkflowsUrl?: string;
    /**
     * Keycloak URL
     * @visibility frontend
     */
    keycloakUrl?: string;
  };
}
