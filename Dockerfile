# EspoCRM packaged for Railway.
#
# Differences from a stock deploy:
#   * The single Railway volume is mounted at /var/www/html/data, NOT at
#     /var/www/html. Upstream treats a mount on the document root as the
#     "legacy" layout and skips installation entirely.
#   * custom/ and client/custom/ are symlinked onto that volume so schema and
#     layout customisations survive a redeploy.
#   * The admin password is re-applied on every boot, so a redeploy is a
#     working password reset.
#   * Apache listens on Railway's injected $PORT.
FROM espocrm/espocrm:10.0.6

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
COPY apache2-foreground /usr/local/sbin/apache2-foreground
RUN chmod +x /usr/local/bin/railway-entrypoint.sh /usr/local/sbin/apache2-foreground \
 && mkdir -p /usr/src/espocrm-custom && mv /var/www/html/custom /usr/src/espocrm-custom/custom && mv /var/www/html/client/custom /usr/src/espocrm-custom/client-custom \
 && ln -s /var/www/html/data/.custom /var/www/html/custom \
 && ln -s /var/www/html/data/.client-custom /var/www/html/client/custom \
 && test -x /usr/local/bin/docker-entrypoint.sh \
 && test -x /usr/local/bin/apache2-foreground

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["apache2-foreground"]

# Literals a template variable cannot carry: Railway drops a literal defaultValue
# at generate time and the variable then publishes as a blank required field.
ENV ESPOCRM_DATABASE_PLATFORM=Postgresql \
    ESPOCRM_DATABASE_PORT=5432 \
    ESPOCRM_DATABASE_NAME=postgres \
    ESPOCRM_DATABASE_USER=postgres \
    ESPOCRM_ADMIN_USERNAME=admin
