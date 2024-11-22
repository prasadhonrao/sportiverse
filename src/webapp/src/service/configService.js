let config = null;

export const fetchConfig = async () => {
  if (!config) {
    try {
      const response = await fetch('/config/config.json');
      if (!response.ok) {
        throw new Error('Failed to fetch configuration');
      }
      const json = await response.json();
      config = json;
    } catch (error) {
      console.error('Error fetching configuration:', error);
      config = {}; // Fallback to an empty object
    }
  }
  return config;
};

export const getConfigValue = async (key) => {
  const config = await fetchConfig();
  return config[key];
};
