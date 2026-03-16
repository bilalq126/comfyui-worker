FROM runpod/worker-comfyui:5.7.1-base

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]